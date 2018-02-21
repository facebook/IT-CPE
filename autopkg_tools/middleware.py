#!/usr/bin/env python2
"""Handle binaries uploaded to package deployment."""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import logging
import os

from cpe.pyexec.core import shell_tools
from cpe.pyexec.modules import scm_tools


class MiddlewarePantriNotFoundException(Exception):
    """Raise if Pantri can't be found."""


class MiddlewarePantriFailException(Exception):
    """Raise if Pantri failed to upload an item."""


def upload_to_pantri(item_path, repo_path):
    """Upload an item to Pantri."""
    pantri_path = os.path.join(repo_path, 'scripts', 'pantri.py')
    if not os.path.isfile(pantri_path):
        raise MiddlewarePantriNotFoundException(
            "Pantri not found at {}".format(pantri_path))
    if not os.path.isfile(item_path):
        raise MiddlewarePantriFailException(
            "File not found at {}".format(item_path)
        )
    cmd = [pantri_path, 'store', item_path]
    result = shell_tools.run_subp(cmd)
    if not result['success']:
        raise MiddlewarePantriFailException(
            "Pantri failed to upload {}: {}".format(
                pantri_path, result['stderr']
            )
        )
    for line in result['stdout'].splitlines():
        logging.debug(line)


def concatenate_shelf_path(item_path, repo_path):
    """Get the full path of an item by joining it to the repo."""
    munki_repo = os.path.join(
        repo_path,
        'shelves',
        'cpe_munki',
        'munki_repo',
        'pkgs'
    )
    real_path = os.path.join(munki_repo, item_path)
    logging.debug('Full item path: {}'.format(real_path))
    return real_path


def binary_middleware(item_path, repo_path):
    """Handle the binary for uploading to package deployment systems."""
    full_item_path = concatenate_shelf_path(item_path, repo_path)
    upload_to_pantri(full_item_path, repo_path)


def push():
    """Push the commit."""
    results = scm_tools.push(['--set-upstream', 'origin', 'HEAD:master'])
    logging.info("Pushing commit: {}".format(results))


def should_we_autocommit(name):
    """Should we autocommit to master?"""
    # Maybe this is where we have source that lists
    # the trusted recipes and their hashes. If the recipe was used to build
    # this item, and it passed verification, we can safely autocommit it.


def middleware_push(branch, name, path):
    """Determine if we should push this to master."""
    # If it's an autocommit, we go ahead and push:
    if should_we_autocommit(name):
        push()
        return
    # Otherwise, generate a diff.
    # arc_diff()
