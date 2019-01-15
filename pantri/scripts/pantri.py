#!/usr/bin/env python
# Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.

import argparse
import os
import sys
import inspect
import platform

# Pantri requires python 2.7 or greater
if not sys.version_info >= (2, 7):
  print 'Pantri requiries python 2.7+. '
  print "Add python2.7 to $PATH or run 'path_to_python27 pantry.py'"
  sys.exit(1)

# Import in respect to the path of script
# http://stackoverflow.com/q/50499
current_frame = inspect.currentframe()
script_path = os.path.abspath(inspect.getfile(current_frame))

# Insert external_deps path to import the correct external modules
external_deps = os.path.join(os.path.dirname(script_path), "external_deps")
sys.path.insert(1, external_deps)

import lib.utils as utils
from lib import logger
from lib.pantri import Pantri

if __name__ == "__main__":
  logger = logger.get_logger()

  def retrieve(options):

    # check if git repo was update before retrieving files.
    pantri = Pantri(options)
    if pantri.nothing_to_retrieve():
      logger.info('it-bin repo already up-to-date. Use -f/--force to override')
      return

    # In order to selectively choose which shelves to retrieve and have
    # different options per shelf, need to call "pantri.retrieve()" for each
    # shelf.
    if 'shelf' in options:
      for shelf in options['shelf']:
        options['shelf'] = shelf

        pantri = Pantri(options)
        pantri.retrieve()
    else:
      pantri = Pantri(options)
      pantri.retrieve()

  def store(options):
    pantri = Pantri(options)
    pantri.store()

  def get_options(args):
    """ Convert cli args into dictionary """
    options = {}
    for arg, value in vars(args).iteritems():
      # Dont include the func arg and null values
      if arg != 'func' and value:
        options.update({arg: value})

      # Add method name ie retrieve or store to options
      if arg == 'func':
        options.update({'method': value.__name__})

    return options

  def delete_json_output_files():
    # Remove update_objects file that might exist from previous run
    json_files = os.path.join(
      utils.get_paths()['scripts'],
      '*_updated_objects.json'
    )
    utils.remove(json_files)

  # Define parser
  parser = argparse.ArgumentParser()
  parser.add_argument(
    '--storage_url', type=str,
    help='Storage URL for object store'
  )
  parser.add_argument(
    '--auth_url', type=str, default=None,
    help='Auth URL for object store'
  )
  parser.add_argument(
    '--object_store_container', type=str, default=None,
    help='Container to upload objects to'
  )
  parser.add_argument(
    '--ignore_patterns', type=str, default=[], nargs='+',
    help='Files on disk to ignore uploading. Supports wildcard patterns.'
  )
  parser.add_argument(
    '--binary_overrides', type=str, default=[], nargs='+',
    help='Text files that should be treated as binaries.' +
    'Supports wildcard patterns.'
  )
  parser.add_argument(
    '-cs', '--checksum', action='store_true', dest='checksum',
    default=False,
    help='Use sha1 checksums to determine if files are different vs ' +
    'file size and modified times'
  )
  parser.add_argument(
    '-p', '--password_file', action='store_true', dest='password_file',
    default=False, help='Use password file for auth'
  )

  # Define subparser for store and retrieve commands
  subparsers = parser.add_subparsers(help="commands")

  # store subparser command and flags
  parser_store = subparsers.add_parser('store')
  parser_store.add_argument(
    'objects', default=[], nargs='*',
    help='List of files or directories to store(upload)'
  )
  parser_store.set_defaults(func=store)

  # retrieve subparser command and flags
  parser_retrieve = subparsers.add_parser('retrieve')
  parser_retrieve.add_argument(
    '-s', '--shelf', type=str, default=[], nargs='*',
    help='Shelf(s) to retrieve'
  )
  parser_retrieve.add_argument(
    '-f', '--force', action='store_true', dest='force',
    default=False, help='Force syncing if repo is up-to-date'
  )
  parser_retrieve.add_argument(
    '-j', '--json_output', action='store_true', dest='json_output',
    default=False,
    help=(
      "Write status of updated objects to"
      " scripts/{shelf}_updated_objects.json"
    )
  )
  parser_retrieve.add_argument(
    '-d', '--dest_sync', type=str, default=None, help='Location to sync files'
  )
  parser_retrieve.add_argument(
    '-i', '--pitem', type=str, dest='pitem',
    default=False, help='Use to reterirve one item'
  )

  # Retain the '-p' flag in the retrieve argparser instance to support existing
  # use-cases. The codebase should be searched for instances of 'retrieve -p'
  # and migrated to having the only the global argparse instance looking for
  # the '-p' flag.
  parser_retrieve.add_argument(
    '-p', '--password_file', action='store_true', dest='password_file',
    default=False, help='Use password file for auth'
  )
  parser_retrieve.set_defaults(func=retrieve)

  # Parse arguments
  args = parser.parse_args()

  # Given that multiple shelves can be retrieved, need to delete the updated
  # objects json file before Pantri.retrieve() is called.
  # Remove once task 13837440 is completed
  delete_json_output_files()

  # Build args into a dict
  options = get_options(args)

  # Run default functions defined for each command.
  args.func(options)
