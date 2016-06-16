#!/usr/bin/python
# encoding: utf-8

from munkilib import munkicommon
from munkilib.phpserialize import *
import subprocess
import pwd
import sys
import urllib
import urllib2
from Foundation import NSArray, NSDate, NSMetadataQuery, NSPredicate
from Foundation import CFPreferencesAppSynchronize
from Foundation import CFPreferencesCopyAppValue
from Foundation import CFPreferencesCopyKeyList
from Foundation import CFPreferencesSetValue
from Foundation import kCFPreferencesAnyUser
from Foundation import kCFPreferencesCurrentUser
from Foundation import kCFPreferencesCurrentHost
import ctypes
import struct
import time
import os

# Check for ssl module
# this will disable the TLS fix on 10.5 and below
try:
    import ssl
    import httplib
    import socket
    TLS = True
except ImportError:
    TLS = False

class TLS1Connection(httplib.HTTPSConnection):
    """Like HTTPSConnection but more specific"""
    def __init__(self, host, **kwargs):
        httplib.HTTPSConnection.__init__(self, host, **kwargs)
 
    def connect(self):
        """Overrides HTTPSConnection.connect to specify TLS version"""
        # Standard implementation from HTTPSConnection, which is not
        # designed for extension, unfortunately
        if getattr(self, 'source_address', None):
            sock = socket.create_connection((self.host, self.port),
                    self.timeout, self.source_address)
        else:
            # Python 2.6 does not use source_address
            sock = socket.create_connection((self.host, self.port),
                    self.timeout)
        if getattr(self, '_tunnel_host', None):
            self.sock = sock
            self._tunnel()
 
        # This is the only difference; default wrap_socket uses SSLv23
        self.sock = ssl.wrap_socket(sock, self.key_file, self.cert_file,
                ssl_version=ssl.PROTOCOL_TLSv1)
 
class TLS1Handler(urllib2.HTTPSHandler):
    """Like HTTPSHandler but more specific"""
    def __init__(self):
        urllib2.HTTPSHandler.__init__(self)
 
    def https_open(self, req):
        return self.do_open(TLS1Connection, req)

if TLS is True:
    # Override default handler
    urllib2.install_opener(urllib2.build_opener(TLS1Handler()))

# our preferences "bundle_id"
BUNDLE_ID = 'MunkiReport'

def set_verbosity(level):
    """
    Set verbosity level
    """
    munkicommon.verbose = int(level)

def display_error(msg, *args):
    """
    Call munkicommon error msg handler
    """
    munkicommon.display_error('Munkireport: %s' % msg, *args)

def display_warning(msg, *args):
    """
    Call munkicommon warning msg handler
    """
    munkicommon.display_warning('Munkireport: %s' % msg, *args)

def display_detail(msg, *args):
    """
    Call munkicommon detail msg handler
    """
    munkicommon.display_detail('Munkireport: %s' % msg, *args)

def curl(url, values):
    req = urllib2.Request(url, urllib.urlencode(values))
    try:
        response = urllib2.urlopen(req)
    except urllib2.URLError, e:
        display_error(url)
        if hasattr(e, 'reason'):
            display_error('We failed to reach a server')
            display_error('Reason: %s' % e.reason)
        elif hasattr(e, 'code'):
            display_error('The server couldn\'t fulfill the request.')
            display_error('Error code: %s' % e.code)
        else:
            display_error('Miscellaneous server error.')
        # Reportserver error, exit clean so munki keeps running
        exit(0)
    except:
        display_error('A server error occurred: %s' % sys.exc_info()[0])
        exit(0)
    return response

def get_long_username(username):
    try:
        long_name = pwd.getpwnam(username)[4]
    except:
        long_name = ''
    return long_name.decode('utf-8')

def get_computername():
    cmd = ['/usr/sbin/scutil', '--get', 'ComputerName']
    proc = subprocess.Popen(cmd, shell=False, bufsize=-1,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, unused_error) = proc.communicate()
    output = output.strip()
    return output.decode('utf-8')

def get_cpuinfo():
    cmd = ['/usr/sbin/sysctl', '-n', 'machdep.cpu.brand_string']
    proc = subprocess.Popen(cmd, shell=False, bufsize=-1,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, unused_error) = proc.communicate()
    output = output.strip()
    return output.decode('utf-8')

def get_uptime():
    """Returns uptime in seconds or None, on BSD (including OS X).
    Copied from https://pypi.python.org/pypi/uptime/1.0.0"""
    try:
        libc = ctypes.CDLL('libc.dylib')
    except OSError:
        return -1

    if not hasattr(libc, 'sysctlbyname'):
        # Not BSD
        return -1

    # Determine how much space we need for the response
    sz = ctypes.c_uint(0)
    libc.sysctlbyname('kern.boottime', None, ctypes.byref(sz), None, 0)
    if sz.value != struct.calcsize('@LL'):
        # Unexpected, let's give up.
        return -1

    # For real now
    buf = ctypes.create_string_buffer(sz.value)
    libc.sysctlbyname('kern.boottime', buf, ctypes.byref(sz), None, 0)
    sec, usec = struct.unpack('@LL', buf.raw)
    up = int(time.time() - sec)
    return up if up > 0 else -1

def set_pref(pref_name, pref_value):
    """Sets a preference, See munkicommon.py for details"""
    CFPreferencesSetValue(
        pref_name, pref_value, BUNDLE_ID,
        kCFPreferencesAnyUser, kCFPreferencesCurrentHost)
    CFPreferencesAppSynchronize(BUNDLE_ID)
    print "set pref"
    try:
        CFPreferencesSetValue(
            pref_name, pref_value, BUNDLE_ID,
            kCFPreferencesAnyUser, kCFPreferencesCurrentHost)
        CFPreferencesAppSynchronize(BUNDLE_ID)
    except Exception:
        pass


def pref(pref_name):
    """Return a preference. See munkicommon.py for details
    """
    pref_value = CFPreferencesCopyAppValue(pref_name, BUNDLE_ID)
    return pref_value

def process(serial, items):
    """Process receives a list of items, checks if they need updating
    and updates them if necessary"""

    # Sanitize serial
    serial = ''.join([c for c in serial if c.isalnum()])

    # Get prefs
    baseurl = pref('BaseUrl') or \
              munkicommon.pref('SoftwareRepoURL') + '/report/'

    hashurl = baseurl + "index.php?/report/hash_check"
    checkurl = baseurl + "index.php?/report/check_in"

    # Get passphrase
    passphrase = pref('Passphrase')

    # Get hashes for all scripts
    for key, i in items.items():
        if i.get('path'):
            i['hash'] = munkicommon.getmd5hash(i.get('path'))

    # Check dict
    check = {}
    for key, i in items.items():
        if i.get('hash'):
            check[key] = {'hash': i.get('hash')}

    # Send hashes to server
    values = {'serial': serial,\
             'items': serialize(check),\
             'passphrase' : passphrase}
    response = curl(hashurl, values)
    server_data = response.read()

    # Decode response
    try:
        result = unserialize(server_data)
    except:
        display_error('Illegal response from the server: %s' % server_data)
        return -1

    if result.get('error') != '':
        display_error('Server error: %s' % result['error'])
        return -1

    # Retrieve hashes that need updating
    for i in items.keys():
        if i in result:
            display_detail('Need to update %s' % i)
            if items[i].get('path'):
                try:
                    f = open(items[i]['path'], "r")
                    items[i]['data'] = f.read()
                except:
                    display_warning("Can't open %s" % items[i]['path'])

        else: # delete items that don't have to be uploaded
            del items[i]

    # Send new files with hashes
    if len(items):
        display_detail('Sending items')
        response = curl(checkurl, {'serial': serial,\
             'items': serialize(items),\
             'passphrase': passphrase})
        display_detail(response.read())
    else:
        display_detail('No changes')

def runExternalScriptWithTimeout(script, allow_insecure=False,\
        script_args=(), timeout=10):
    """Run a script (e.g. preflight/postflight) and return its exit status.

    Args:
      script: string path to the script to execute.
      allow_insecure: bool skip the permissions check of executable.
      args: args to pass to the script.
    Returns:
      Tuple. (integer exit status from script, str stdout, str stderr).
    Raises:
      ScriptNotFoundError: the script was not found at the given path.
      RunExternalScriptError: there was an error running the script.
    """
    from munkilib import utils

    if not os.path.exists(script):
        raise ScriptNotFoundError('script does not exist: %s' % script)

    if not allow_insecure:
        try:
            utils.verifyFileOnlyWritableByMunkiAndRoot(script)
        except utils.VerifyFilePermissionsError, e:
            msg = ('Skipping execution due to failed file permissions '
                   'verification: %s\n%s' % (script, str(e)))
            raise utils.RunExternalScriptError(msg)

    if os.access(script, os.X_OK):
        cmd = [script]
        if script_args:
            cmd.extend(script_args)
        proc = subprocess.Popen(cmd, shell=False,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        while timeout > 0:
            if proc.poll() is not None:
                (stdout, stderr) = proc.communicate()
                return proc.returncode, stdout.decode('UTF-8', 'replace'), \
                                        stderr.decode('UTF-8', 'replace')
            time.sleep(0.1)
            timeout -= 0.1
        else:
            try:
                proc.kill()
            except OSError, e:
                if e.errno != 3:
                    raise
            raise utils.RunExternalScriptError('%s timed out' % script)
        return (0, None, None)

    else:
        raise utils.RunExternalScriptError('%s not executable' % script)

def rundir(scriptdir, runtype, abort=False, submitscript=''):
    """
    Run scripts in directory scriptdir
    runtype is passed to the script
    if abort is True, a non-zero exit status will abort munki
    submitscript is put at the end of the scriptlist
    """
    if os.path.exists(scriptdir):

        from munkilib import utils

        # Directory containing the scripts
        parentdir = os.path.basename(scriptdir)
        display_detail('# Executing scripts in %s' % parentdir)

        # Get all files in scriptdir
        files = os.listdir(scriptdir)

        # Sort files
        files.sort()

        # Find submit script and stick it on the end of the list
        if submitscript:
            try:
                sub = files.pop(files.index(submitscript))
                files.append(sub)
            except Exception, e:
                display_error('%s not found in %s' % (submitscript, parentdir))

        for script in files:

            # Skip files that start with a period
            if script.startswith('.'):
                continue

            # Concatenate dir and filename
            scriptpath = os.path.join(scriptdir, script)

            # Skip directories
            if os.path.isdir(scriptpath):
                continue

            try:
                # Attempt to execute script
                display_detail('Running %s' % script)
                result, stdout, stderr = runExternalScriptWithTimeout(
                    scriptpath, allow_insecure=False, script_args=[runtype])
                if stdout:
                    display_detail(stdout)
                if stderr:
                    display_detail('%s Error: %s' % (script, stderr))
                if result:
                    if abort:
                        display_detail('Aborted by %s' % script)
                        exit(1)
                    else:
                        display_warning('%s return code: %d'\
                            % (script, result))

            except utils.ScriptNotFoundError:
                pass  # Script has disappeared - pass.
            except utils.RunExternalScriptError, e:
                display_warning(str(e))

# End of reportcommon
