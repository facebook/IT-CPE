# Copyright (c) Facebook, Inc. and its affiliates. All rights reserved.
import os

import utils


repo_root = utils.get_paths()['repo_root']
""" Default config options"""
default = {
  'storage_url': 'https://example.com',
  'auth_url': 'https://example.com/auth/',
  'object_store_container': 'blah',
  'ignore_patterns': [
    '._*',
    '.__*',
    '.TemporaryItems*',
    '._.TemporaryItems',
    '.DS_Store',
    '*.pyc',
  ],
  'dest_sync': os.path.join(repo_root, 'dest_sync'),
  'checksum': False,
  'binary_overrides': []
}

example_shelf = {
  'dest_sync': repo_root
}

example_shelf_2 = {
  'binary_overrides': ['*.inf', '*.din']
}


def get_options(shelf_dir, override_options):
  """
  Merge all config options.

  Precedence CLI options > shelf_dir options > default options
  """

  options = default.copy()
  try:
    options.update(globals().get(shelf_dir))
  except:
    pass

  try:
    options.update(override_options)
  except:
    pass

  return options
