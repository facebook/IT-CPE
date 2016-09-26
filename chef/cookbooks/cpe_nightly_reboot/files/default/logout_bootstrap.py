#!/usr/bin/python
"""Forced logout + Munki bootstrap."""

import sys
import os
import signal

with open('/private/etc/paths.d/munki', 'rb') as f:
  munkipath = f.read().strip()
sys.path.append(os.path.join(munkipath, 'munkilib'))

try:
  import munkicommon
except ImportError:
  sys.exit(-1)

munki_bootstrap = \
  '/Users/Shared/.com.googlecode.munki.checkandinstallatstartup'

open(munki_bootstrap, 'w').close()

print "Forcing logout..."
try:
  # Code modified from munkicommon.forceLogoutNow()
  procs = munkicommon.findProcesses(exe=munkicommon.LOGINWINDOW)
  users = {}
  for pid in procs:
    users[procs[pid]['user']] = pid

  if 'root' in users:
    del users['root']

  # kill loginwindows to cause logout of current users, whether
  # active or switched away via fast user switching.
  for user in users:
    try:
      os.kill(users[user], signal.SIGKILL)
    except OSError:
      pass
except BaseException, err:
  print >> sys.stderr, 'Exception in forceLogoutNow(): %s' % str(err)
