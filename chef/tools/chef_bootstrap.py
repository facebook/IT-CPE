#!/usr/bin/python
"""Bootstrap Chef with no other dependencies."""

import os
import sys
import platform
import subprocess
import json
import plistlib
import urllib2
import glob

import objc
from Foundation import NSBundle

CLIENT_RB = """
log_level              :info
log_location           STDOUT
validation_client_name 'YOUR_ORG_NAME-validator'
validation_key         File.expand_path('/etc/chef/validation.pem')
chef_server_url        "YOUR_CHEF_SERVER_URL_GOES_HERE"
json_attribs           '/etc/chef/run-list.json'
ssl_ca_file            '/etc/chef/YOUR_CERT.crt'
ssl_verify_mode        :verify_peer
local_key_generation   true
rest_timeout           30
http_retry_count       3
no_lazy_load           false

whitelist = [
]
automatic_attribute_whitelist whitelist
default_attribute_whitelist []
normal_attribute_whitelist []
override_attribute_whitelist []
"""

RUN_LIST_JSON = {"run_list": ["role[cpe_base]"]}

VALIDATION_PEM = """
-----BEGIN RSA PRIVATE KEY-----
validation pem goes here
-----END RSA PRIVATE KEY-----
"""

ORG_CRT = """
-----BEGIN CERTIFICATE-----
your certificate goes here
-----END CERTIFICATE-----
"""


# OS-related functions
def get_os_version():
  """Return OS version."""
  return platform.mac_ver()[0]


def get_serial():
  """Get system serial number."""
  # Credit to Mike Lynn
  IOKit_bundle = NSBundle.bundleWithIdentifier_("com.apple.framework.IOKit")
  functions = [
    ("IOServiceGetMatchingService", b"II@"),
    ("IOServiceMatching", b"@*"),
    ("IORegistryEntryCreateCFProperty", b"@I@@I")
  ]
  objc.loadBundleFunctions(IOKit_bundle, globals(), functions)

  kIOMasterPortDefault = 0
  kIOPlatformSerialNumberKey = 'IOPlatformSerialNumber'
  kCFAllocatorDefault = None

  platformExpert = IOServiceGetMatchingService(
    kIOMasterPortDefault,
    IOServiceMatching("IOPlatformExpertDevice")
  )
  serial = IORegistryEntryCreateCFProperty(
    platformExpert,
    kIOPlatformSerialNumberKey,
    kCFAllocatorDefault,
    0
  )
  return serial


def getconsoleuser():
  """Get the current console user."""
  from SystemConfiguration import SCDynamicStoreCopyConsoleUser
  cfuser = SCDynamicStoreCopyConsoleUser(None, None, None)
  return cfuser[0]


# Convenience functions to run subprocesses
def run_live(command):
  """
  Run a subprocess with real-time output.

  Can optionally redirect stdout/stderr to a log file.
  Returns only the return-code.
  """
  # Validate that command is not a string
  if isinstance(command, basestring):
    # Not an array!
    raise TypeError('Command must be an array')
  # Run the command
  proc = subprocess.Popen(command,
                          stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT)
  while proc.poll() is None:
    l = proc.stdout.readline()
    print l,
  print proc.stdout.read()
  return proc.returncode


def run_subp(command, input=None):
  """
  Run a subprocess.

  Command must be an array of strings, allows optional input.
  Returns results in a dictionary.
  """
  # Validate that command is not a string
  if isinstance(command, basestring):
    # Not an array!
    raise TypeError('Command must be an array')
  proc = subprocess.Popen(command,
                          stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT)
  (out, err) = proc.communicate(input)
  result_dict = {
    "stdout": out,
    "stderr": err,
    "status": proc.returncode,
    "success": True if proc.returncode == 0 else False
  }
  return result_dict


def run_log(command, stdout_path):
  """
  Run a subprocess with all output logged to a file.

  Return the subprocess return code.
  """
  if isinstance(command, basestring):
    # Not an array!
    raise TypeError('Command must be an array')
  with open(stdout_path, 'ab') as f:
    proc = subprocess.Popen(command, stdout=f, stderr=subprocess.STDOUT)
    proc.wait()
  return proc.returncode


def osascript(osastring):
  """Wrapper to run AppleScript commands."""
  cmd = ['/usr/bin/osascript', '-e', osastring]
  proc = subprocess.Popen(cmd, shell=False, bufsize=1,
                          stdin=subprocess.PIPE,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  (out, err) = proc.communicate()
  if proc.returncode != 0:
    print >> sys.stderr, 'Error: ', err
  if out:
    return str(out).decode('UTF-8').rstrip('\n')


# Package-related functions
def get_pkg_path_from_dmg(dmgpath):
  """Get the path of a .pkg inside a DMG."""
  mountpoints = []
  cmd = ['/usr/bin/hdiutil', 'attach', dmgpath,
         '-mountRandom', '/tmp', '-nobrowse', '-plist']
  results = run_subp(cmd)
  if not results['success']:
    print >> sys.stderr, ("Failed to mount "
                          "%s: %s" % (dmgpath, results['stderr']))
    return None
  pliststr = results['stdout']
  if pliststr:
    plist = plistlib.readPlistFromString(pliststr)
    for entity in plist.get('system-entities', []):
      if 'mount-point' in entity:
        mountpoints.append(entity['mount-point'])
    if mountpoints:
      pkg_path = os.path.join(mountpoints[0], '*.pkg')
      return glob.glob(pkg_path)[0]


def install_package(package_path):
  """Install a package."""
  path = package_path
  if package_path.endswith('.dmg'):
    # Search the DMG for a valid .pkg
    path = get_pkg_path_from_dmg(package_path)
    if not path:
      # Package failed to install, we can't proceed.
      return False
  cmd = [
    '/usr/sbin/installer', '-pkg',
    path,
    '-target', 'LocalSystem'
  ]
  proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
  )
  (out, err) = proc.communicate()
  if proc.returncode != 0:
    print >> sys.stderr, out
    return False
  print out
  return True


def is_pkg_installed(receipt):
  """
  Check if a package receipt is installed.

  Returns version of package installed, or '0.0.0.0'.
  """
  proc = subprocess.Popen(['/usr/sbin/pkgutil',
                           '--pkg-info-plist', receipt],
                          bufsize=1,
                          stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE)
  (out, dummy_err) = proc.communicate()
  if proc.returncode != 0:
    return '0.0.0.0'
  plist = plistlib.readPlistFromString(out)
  foundbundleid = plist.get('pkgid')
  foundvers = plist.get('pkg-version', '0.0.0.0.0')
  if receipt == foundbundleid:
    return foundvers


def install_cli_tools():
  """Install the Xcode CLI tools, from Apple if necessary."""
  os_ver = get_os_version()
  # Install command line tools if necessary:
  # 10.12 receipt name
  receipt = 'com.apple.pkg.DevSDK_OSX1012'
  desired_platform = 'macOS Sierra'
  if '10.11' in os_ver:
    receipt = 'com.apple.pkg.DevSDK_OSX1011'
    desired_platform = 'OS X 10.11'
  if (
    is_pkg_installed('com.apple.pkg.CLTools_Executables') != '0.0.0.0' and
    is_pkg_installed(receipt) != '0.0.0.0'
  ):
    print "installed."
    return True
  else:
    print "not installed."
    # We need to install the CLI tools from Apple
    # https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/install_xcode_command_line_tools  # noqa
    tmpfile = \
      '/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress'
    open(tmpfile, 'wb').close()
    results = run_subp(['/usr/sbin/softwareupdate', '-l'])
    if int(results['status']) != 0:
      print >> sys.stderr, ('Software update failed!')
      sys.exit(1)
    for line in results['stdout'].split('\n'):
      if 'Command Line Tools' in line and desired_platform in line:
        cmd_line_tools = line.split('* ')[1]
        cmd = ['/usr/sbin/softwareupdate', '-i', cmd_line_tools, '--verbose']
        results = run_live(cmd)
        break
    if results != 0:
      print >> sys.stderr, ('Software update failed!')
      sys.exit(1)
    os.remove(tmpfile)
    # Check to see if we succeeded
    if (
      is_pkg_installed('com.apple.pkg.CLTools_Executables') != '0.0.0.0' and
      is_pkg_installed(receipt) != '0.0.0.0'
    ):
      print "CLI tools installed."
      return True
    # The receipts aren't present, so we can't consider it a valid install.
    return False


# Chef-related functions
def get_chef():
  """Determine source of Chef."""
  # Try downloading direct from Chef website
  os_ver = '.'.join(get_os_version().split('.')[:2])
  base_url = 'https://www.chef.io/chef/download'
  url = ('%s?p=mac_os_x&pv=%s&m=x86_64&v=latest&prerelease=false' %
        (base_url, os_ver))
  # Chef redirects to an AWS node
  actual_url = urllib2.urlopen(url).geturl()
  file_name = 'chef.dmg'
  print 'Downloading from Chef directly...',
  with open(os.path.join('/tmp', file_name), 'wb') as f:
    f.write(urllib2.urlopen(actual_url).read())
  if os.path.exists(os.path.join('/tmp', file_name)):
    print 'downloaded from Chef.io.'
    return os.path.join('/tmp', file_name)
  # If we're here, we got nothing.
  return None


def install_chef():
  """Install Chef client package."""
  # Is Chef installed?
  chef_vers = is_pkg_installed('com.getchef.pkg.chef')
  if chef_vers != '0.0.0.0' and os.path.exists('/opt/chef/bin/chef-client'):
    print "Chef %s installed" % chef_vers
    return True
  # Is Chef locally available in /Library/Chef/Source?
  localchef = glob.glob('/Library/Chef/Source/chef-*.pkg')
  if localchef and os.path.isfile(localchef[-1]):
    print "Using %s" % localchef
    install_path = localchef[-1]
  else:
    print "Obtaining Chef..."
    install_path = get_chef()
  # Install the package
  if not install_path:
    print >> sys.stderr, "Couldn't download Chef."
    sys.exit(1)
  print "Installing Chef."
  result = install_package(install_path)
  if not result:
    print >> sys.stderr, "Could not install Chef."
    return False
  print "Finished installing Chef."
  return True


def client(logpath, prams=[], chef_path='/usr/local/bin/chef-client'):
  """Run chef-client with parameter list, return result code."""
  cmd = [chef_path]
  cmd.extend(prams)
  print "Running client, saving output to %s" % logpath
  return run_log(cmd, logpath)


def run_chef(logpath='/Library/Chef/Logs/first_chef_run.log'):
  """Run Chef."""
  # Try a live Chef run, to a log file.
  result = client(logpath)
  if result == 0:
    # exit code of 0 means it succeeded
    return True
  return False


# Primary bootstrap function
def bootstrap(force=False):
  """
  Bootstrap a machine using Chef.

  Installs the Xcode Command Line Tools first.
  Copies the default client.rb, run_list.json, validation.pem into place.
  Appends the nodename and ohai to the client.rb.
  Installs the Chef package (will download first if necessary).
  Run chef-client for the first time while logging to
  /Library/Chef/Logs/first_chef_run.log

  If local=True, it will do a chef-zero with local files only.

  Returns True/False if it succeeded or failed.
  """
  # OS Version check:
  os_ver = get_os_version()
  if int(os_ver.split('.')[1]) < 10:
    print (
      "%s is no longer supported. This machine must "
      "be upgraded to install Chef." % os_ver
    )
    return False

  # If current user is 'admin', we should abort, because Chef will
  # install a local admin account with a randomized password
  if getconsoleuser() == 'admin':
    print ("Create a new administrative account "
           "not named 'admin'!\nChef will create an "
           "'admin' account for you.")
    return False

  # Install the Xcode Command Line Tools first
  print "Checking for OS X CLI Tools...",
  cli_success = install_cli_tools()
  if not cli_success:
    print (
      "Unable to install Xcode Command Line Tools!"
    )
    return False

  if force:
    try:
      if os.path.isfile("/etc/chef/client.pem"):
        os.remove("/etc/chef/client.pem")
      if os.path.exists("/etc/chef/ohai_plugins/"):
        os.remove("/etc/chef/ohai_plugins/")
    except:
      pass

  # Set up config files
  print "Setting up Chef config files."
  serial = get_serial()
  # Adding Node name based on serial number, and Ohai config changes.
  global CLIENT_RB
  CLIENT_RB += '\n' + 'node_name \"%s\"' % serial
  CLIENT_RB += '\n' + 'Ohai::Config[:plugin_path] << "/etc/chef/ohai_plugins"'
  CLIENT_RB += '\n' + 'Ohai::Config[:disabled_plugins] = [:Passwd]'

  if not os.path.isdir('/etc/chef'):
    os.makedirs('/etc/chef')
  with open('/etc/chef/client.rb', 'wb') as f:
    f.write(CLIENT_RB)
  with open('/etc/chef/run-list.json', 'wb') as f:
    json.dump(RUN_LIST_JSON, f)
  with open('/etc/chef/org.crt', 'wb') as f:
    f.write(ORG_CRT)
  with open('/etc/chef/validation.pem', 'wb') as f:
    f.write(VALIDATION_PEM)

  # Install the Chef client package.
  print "Checking for Chef install..."
  chef_installed = install_chef()
  if not chef_installed:
    print "Bootstrap failed."
    return False

  # Set the firstboot tag to ensure the firstboot runlist is used.
  open('/etc/chef/firstboot', 'wb').close()

  # Set up the basic Chef directory
  if not os.path.isdir('/Library/Chef/Logs'):
    os.makedirs('/Library/Chef/Logs')

  sys.stdout.flush()
  # Run Chef at least twice, but retry a certain number of times
  retries = 3
  successes = 0
  while True:
    success = run_chef()
    if success:
        successes += 1
    else:
        print "Run failed, retrying..."
        retries -= 1
    if successes == 2 or retries == 0:
      break

  if successes < 2:
    print (
      "Chef failed to run, please send the logfile at"
      " /Library/Chef/Logs/first_chef_run.log!"
    )
    return False

  # All done!
  print "Bootstrap complete!"
  return True


if __name__ == '__main__':
  result = bootstrap(force=True)
  if not result:
    sys.exit(1)
