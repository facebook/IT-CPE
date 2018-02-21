#!/usr/bin/env python2

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import json
import logging
import os
import shutil

from cpe.pyexec.mm import autopkg_tools
from cpe.pyexec.mm import middleware
from cpe.pyexec.modules import FoundationPlist
from cpe.pyexec.modules import pref_tools
from cpe.pyexec.modules import scm_tools


AUTOPKG_TOOLS_BUNDLE_ID = "com.facebook.CPE.autopkg"


class MMUpdateBadPreferencesException(Exception):
    """Raise if a bad argument or local preference is unresolved."""


class MMUpdateRunlistException(Exception):
    """Unable to read the runlist."""


def get_aptools_pref(key):
    """Get a preference from the CPE autopkg domain."""
    return pref_tools.get_pref(key, AUTOPKG_TOOLS_BUNDLE_ID)


def add_argparser(ap_sub):
    """Take an argparse subparser and add args."""
    # Set default function call
    ap_sub.set_defaults(func=main)
    # Either provide a list of recipes via args, or a file containing them
    recipe_group = ap_sub.add_mutually_exclusive_group()
    recipe_group.add_argument(
        '-l', '--list', help='Path to a plist or JSON list of recipe names.'
    )
    recipe_group.add_argument('-r', '--recipes', nargs='+', help='Recipes to run.')
    ap_sub.add_argument(
        '-g',
        '--gitrepo',
        help='Path to git repo. Overrides preference.',
    )
    ap_sub.add_argument(
        '-a',
        '--arc',
        help='Use arcanist instead of git for branches.  Overrides preference.',
        action='store_true',
        default=False
    )
    ap_sub.add_argument(
        '-p',
        '--pkg',
        help=(
            'Path to a pkg or dmg to provide to a recipe.\n'
            'Ignored if you pass in more than once recipe to -r,'
            ' or -l.'
        ),
    )


def copy_hashfile_to_itbin(hashfile, prefs):
    """Copy the hash file from ContentHasher into IT-Bin."""
    hashes_folder = os.path.join(prefs['git_repo'], 'hashes')
    try:
        os.mkdir(hashes_folder)
    except OSError:
        # Already exists
        pass
    shutil.copy2(hashfile, hashes_folder)


def parse_recipe_list(file_path):
    """Parse a recipe list from a file path. Supports JSON or plist."""
    logging.debug("parse_recipe_list: Parsing recipe list")
    recipe_list = []
    extension = os.path.splitext(file_path)[1]
    try:
        if extension == '.json':
            with open(file_path, 'rb') as f:
                recipe_list = json.load(f)
        elif extension == '.plist':
            recipe_list = FoundationPlist.readPlist(file_path)
    except Exception:
        raise MMUpdateRunlistException(
            "Unable to read recipe list at {}".format(file_path)
        )
    logging.debug("autopkg_tools: Recipe list: {}".format(recipe_list))
    return recipe_list


def validate_prefs(args):
    """Validate the arguments and local preferences."""
    prefs_dict = {
        'git_repo': get_aptools_pref('GitRepo') or args.gitrepo,
        'arc': get_aptools_pref('UseArcanist') or args.arc or False,
        'list': [],
    }
    if not prefs_dict['git_repo']:
        raise MMUpdateBadPreferencesException(
            "No path to git repo provided")
    if not os.path.isdir(prefs_dict['git_repo']):
        raise MMUpdateBadPreferencesException(
            "Path {} does not exist".format(prefs_dict['git_repo']))
    if prefs_dict['arc'] and not os.path.exists(scm_tools.ARC):
        raise MMUpdateBadPreferencesException("Arcanist not available!")
    # Did we get a list, or recipes?
    if args.list:
        # Does the file exist?
        if not os.path.isfile(args.list):
            raise MMUpdateBadPreferencesException(
                "Recipe list {} not found!".format(args.list))
        # Parse the file and make sure we got valid data from it
        prefs_dict['list'] = parse_recipe_list(args.list)
        if not prefs_dict['list']:
            raise MMUpdateBadPreferencesException("Recipe list is empty!")
    if args.recipes:
        prefs_dict['list'] = args.recipes
    # Did we get a specific package?
    if args.pkg:
        if len(prefs_dict['list']) != 1 or args.list:
            raise MMUpdateBadPreferencesException(
                "Cannot use -p with multiple recipes")
        prefs_dict['pkg'] = args.pkg
    prefs_dict['verbose'] = args.verbose
    return prefs_dict


def run_autopkg_recipe(recipe_name, prefs):
    """Run an autopkg recipe."""
    logging.info('Handling {}'.format(recipe_name))
    # Parse recipe name for basic item name
    branchname = autopkg_tools.parse_recipe_name(recipe_name)
    # Create feature branch
    scm_tools.create_feature_branch(branchname, prefs['arc'])
    # Run autopkg for this recipe
    recipe_obj = autopkg_tools.AutoPkgRecipe(recipe_name)
    recipe_obj.run(prefs['verbose'])
    if not recipe_obj.imported_items and not recipe_obj.failed_items:
        # Nothing happened for this recipe (since we don't really
        # care about downloads).
        logging.info('Nothing changed for {}'.format(recipe_name))
        scm_tools.cleanup_branch(branchname)
        return
    if recipe_obj.failed_items:
        # Normally, 'failed_items' is a list of all recipe failures
        # parsed from the report plist. Since we are only running one
        # recipe at a time, we know that any failures must be this one.
        failed_recipe = recipe_obj.failed_items[0]
        logging.warn('{} failed: {}'.format(
            failed_recipe.recipe, failed_recipe.message))
        scm_tools.cleanup_branch(branchname)
        return
    if recipe_obj.imported_items:
        # Like 'failed_items', 'imported_items' is a list of all recipe
        # failures parsed from the report plist. Since we are only running
        # one recipe at a time, we know this was imported.
        imported_item = recipe_obj.imported_items[0]
        logging.info('Imported {}'.format(imported_item.name))
        # Item succeeded, so continue.
        # Did we generate a content hash?
        if recipe_obj.hashfile:
            copy_hashfile_to_itbin(recipe_obj.hashfile, prefs)
        # Run any binary-handling middleware
        middleware.binary_middleware(imported_item.path, prefs['git_repo'])
        # Rename the branch with version
        new_branchname = scm_tools.rename_branch_version(  # NOQA
            branchname, imported_item.version)
        # Create git commit
        message = imported_item.name + '-' + imported_item.version
        scm_tools.create_commit(prefs['git_repo'], message)
        # Pass it on to middleware for pushing
        # middleware_push(
        #     new_branchname,
        #     imported_item.name,
        #     imported_item.path
        # )
        # Cleanup now that we're done
        # scm_tools.cleanup_branch(new_branchname)
        # scm_tools.pull()


def main(args):
    """Handle the complete workflow of an autopkg recipe."""
    logging.debug('Running update')
    # parse preferences for validity
    prefs = validate_prefs(args)
    # Change directory to the git repo first
    os.chdir(prefs['git_repo'])
    for recipe_name in prefs['list']:
        run_autopkg_recipe(recipe_name, prefs)
