#!/usr/bin/python
#
# These are utility functions used by other parts of the AutoDMG build tools

import subprocess
import hashlib
import os
import tempfile
import shutil


def run(cmd, disowned=False):
  '''Runs a command with subprocess, printing output in realtime'''
  proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE if not disowned else None,
    stderr=subprocess.STDOUT if not disowned else None
  )
  if not disowned:
    while proc.poll() is None:
      l = proc.stdout.readline()
      print l,
    print proc.stdout.read()


def pkgbuild(root_dir, identifier, version, pkg_output_file):
  '''Builds a package from root_dir with identifier and version
    into the path of pkg_output_file'''
  cmd = [
    '/usr/bin/pkgbuild',
    '--root', root_dir,
    '--identifier', identifier,
    '--version', version,
    pkg_output_file]
  run(cmd)


def hash_file(path):
  '''Calculates an SHA256 hash of a file'''
  # http://stackoverflow.com/a/3431835
  blocksize = 65536
  hasher = hashlib.sha256()
  with open(path, 'rb') as f:
    buf = f.read(blocksize)
    while len(buf) > 0:
        hasher.update(buf)
        buf = f.read(blocksize)
    return hasher.hexdigest()


def build_pkg(source, output, receipt, destination, cache_dir, comment=''):
  '''Construct a FB-only package with our specific features'''
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
    pkg_hash = hash_file(output_file)
    # Clean up after ourselves
    shutil.rmtree(temp_dir, ignore_errors=True)
    # Return the package hash
    return pkg_hash
  # If nothing was built, return empty string
  return ''


def populate_ds_repo(image_path, repo):
  '''Moves a built image into the DS repo'''
  repo_hfs = os.path.join(repo, 'Masters', 'HFS')
  image_name = os.path.basename(image_path)
  if not image_path.endswith('.hfs.dmg') and image_path.endswith('.dmg'):
    # DS masters must end in '.hfs.dmg'
    print 'Renaming image to ".hfs.dmg" for DS support'
    image_name = image_name.split('.dmg')[0] + '.hfs.dmg'
  repo_target = os.path.join(repo_hfs, image_name)
  if os.path.isfile(repo_target):
    # If the target already exists, name it "-OLD"
    print "Renaming old image."
    os.rename(repo_target, repo_target + '-OLD')
  # now copy the newly built image over
  print "Copying new image to DS Repo."
  print "Image path: %s" % image_path
  print "Repo target: %s" % repo_target
  shutil.copyfile(image_path, repo_target)
