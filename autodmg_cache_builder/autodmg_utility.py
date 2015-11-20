#!/usr/bin/python
#
# These are utility functions used by other parts of the AutoDMG build tools

import subprocess
import sys


def run(cmd, error_text=''):
  '''Runs a command with subprocess, returns a tuple of out/err'''
  proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
  )
  (out, err) = proc.communicate()
  print out
  errors = err
  if error_text:
    errors = "%s: %s" % (error_text, err)
  if (err):
    print >> sys.stderr, errors
    sys.exit(-1)


def pkgbuild(root_dir, identifier, version, pkg_output_file):
  '''Builds a package from root_dir with identifier and version
    into the path of pkg_output_file'''
  cmd = [
    '/usr/bin/pkgbuild',
    '--root', root_dir,
    '--identifier', identifier,
    '--version', version,
    pkg_output_file]
  run(cmd, "Pkgbuild error")
