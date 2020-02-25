#!/usr/bin/python
# Copyright (c) Facebook, Inc. and its affiliates.
"""Utility functions used by other parts of the AutoDMG build tools."""

import subprocess
import os
import tempfile
import shutil


def run(cmd):
  """Run a command with subprocess, printing output in realtime."""
  proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT
  )
  while proc.poll() is None:
    l = proc.stdout.readline()
    print l,
  print proc.stdout.read()
  return proc.returncode


def pkgbuild(root_dir, identifier, version, pkg_output_file):
  """Build a package from root_dir at pkg_output_file."""
  cmd = [
    '/usr/bin/pkgbuild',
    '--root', root_dir,
    '--identifier', identifier,
    '--version', version,
    pkg_output_file]
  run(cmd)


def build_pkg(source, output, receipt, destination, cache_dir, comment=''):
  """
  Construct package using pkgbuild.

  source - the directory to build a package from
  output - the name of the package file to build ('.pkg' is appended)
  receipt - the receipt of the package
  destination - the directory path to place the payload in
  cache_dir - the directory to place the built package into
  comment - A message to print out when building
  """
  if os.path.isdir(source) and os.listdir(source):
    print comment
    pkg_name = '%s.pkg' % output
    # We must copy the contents into a temp folder and build
    prefix = 'cpe_%s' % receipt.split('.')[-1]
    temp_dir = tempfile.mkdtemp(prefix=prefix, dir='/tmp')
    pkg_dir = os.path.join(temp_dir, destination.lstrip('/'))
    # Copy the contents of the folder into place
    shutil.copytree(source, pkg_dir)
    # Build the package
    output_file = os.path.join(cache_dir, pkg_name)
    pkgbuild(
      temp_dir,
      receipt,
      '1.0',
      output_file
    )
    # Clean up after ourselves
    shutil.rmtree(temp_dir, ignore_errors=True)
    # Return the path to the package
    if os.path.isfile(output_file):
      return output_file
  # If nothing was built, return empty string
  return ''


def populate_ds_repo(image_path, repo):
  """Move a built image into the DS repo."""
  repo_hfs = os.path.join(repo, 'Masters', 'HFS')
  image_name = os.path.basename(image_path)
  if not image_path.endswith('.hfs.dmg') and image_path.endswith('.dmg'):
    # DS masters must end in '.hfs.dmg'
    print 'Renaming image to ".hfs.dmg" for DS support'
    image_name = image_name.split('.dmg')[0] + '.hfs.dmg'
  repo_target = os.path.join(repo_hfs, image_name)
  if os.path.isfile(repo_target):
    # If the target already exists, name it "-OLD"
    newname = repo_target.split('.hfs.dmg')[0] + '-OLD.hfs.dmg'
    print "Renaming old image to %s" % newname
    os.rename(repo_target, newname)
  # now copy the newly built image over
  print "Copying new image to DS Repo."
  print "Image path: %s" % image_path
  print "Repo target: %s" % repo_target
  shutil.move(image_path, repo_target)
