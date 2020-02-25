#!/usr/bin/python
# Copyright (c) Facebook, Inc. and its affiliates.
"""Tools to manage the run of AutoPkg."""

import sys
import imp
import subprocess
import os
import json
import time
import argparse

try:
    import yaml
    YAML_INSTALLED = True
except ImportError:
    YAML_INSTALLED = False

try:
  from Foundation import NSDate
  from Foundation import CFPreferencesAppSynchronize
  from Foundation import CFPreferencesCopyAppValue
  from Foundation import CFPreferencesSetValue
  from Foundation import kCFPreferencesCurrentUser
  from Foundation import kCFPreferencesCurrentHost
except ImportError:
  print >> sys.stderr, "Can't import Foundation!"
  # Exit so this doesn't break our unit tests
  sys.exit(0)

# Append autopkg to the Python path
sys.path.append('/Library/AutoPkg')
try:
  import FoundationPlist
except ImportError:
  print "Can't find Foundation Plist!"
  sys.exit(1)
try:
  import autopkglib
except ImportError:
  print "Can't find autopkglib!"
  sys.exit(1)

imp.load_source('autopkg', '/usr/local/bin/autopkg')
try:
  import autopkg
except ImportError:
  print "Can't import autopkg!"
  sys.exit(1)

GIT = '/usr/bin/git'
VERBOSE = 0
REPO_DIR = '/Users/Shared/autopkg'
USE_ARCANIST = False
DEV = False
BUNDLE_ID = 'com.facebook.CPE.autopkg'


class Error(Exception):
  """Base class for domain-specific exceptions."""


class BranchError(Error):
  """Branch-related exceptions."""


class RunError(Error):
  """AutoPkg Run exceptions."""


class GitError(Error):
  """Git exceptions."""


class RunlistError(Error):
  """Unable to read the runlist."""


# AutoPkg recipe-handling
def parent_recipes(identifier):
  """Get the list of all recipe files for a given identifier."""
  # display_verbose("Calling parent_recipes for %s" % identifier)
  recipe = autopkg.load_recipe(
    identifier,
    autopkg.get_override_dirs(),
    autopkg.get_search_dirs(),
    make_suggestions=None,
    search_github=False,
  )
  # Recipes that don't exist will still have no parents
  pathlist = []
  if recipe:
    pathlist = recipe.get('PARENT_RECIPES', [])
    pathlist.append(recipe.get('RECIPE_PATH'))
    display_verbose("List of recipe files: %s" % pathlist)
    return pathlist
  return []


def parse_recipe_name(identifier):
  """Get the name of the recipe."""
  # display_verbose("Calling parse_recipe_name")
  branch = identifier.replace(' ', '-').lower().split('.munki')[0]
  # Check to see if branch name already exists
  current_branches = branch_list()
  if branch in current_branches:
    # If the same name already exists, append a '-2' to it
    branch += '-2'
  return branch


# Convenience utilities
def timeprint(message, newline=True):
  """Print out message with a timestamp."""
  hostname = run_cmd(['/usr/sbin/scutil', '--get', 'HostName'])['stdout']
  tag = 'autopkg_tools'
  current_time = time.strftime("%c")
  content = '%s %s %s: %s' % (
    current_time,
    hostname.rstrip(),
    tag,
    str(message)
  )
  if not newline:
    print content,
    return
  print content


def run_cmd(cmd):
  """Run a command and return the output."""
  proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
  )
  (out, err) = proc.communicate()
  results_dict = {
    'stdout': out,
    'stderr': err,
    'status': proc.returncode,
    'success': proc.returncode == 0
  }
  return results_dict


def run_live(command):
  """
  Run a subprocess with real-time output.

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
    timeprint(l, newline=False)
  leftover = proc.stdout.read()
  for line in leftover.splitlines():
    timeprint(line)
  return proc.returncode


def display_verbose(content):
  """Display verbose content."""
  if VERBOSE > 0:
    timeprint(content)


def read_preferences(args):
  """Read our preferences and return a dict."""
  prefs_dict = {}
  # Equivalent to -l/--list
  prefs_dict['runlist'] = args.list or get_pref('RunList') or []
  # Equivalent to -v/--verbose
  prefs_dict['verbosity'] = (
    bool(args.verbose or get_pref('DebugMode')) or
    False
  )
  # Equivalent to -g/--gitrepo
  prefs_dict['repo_dir'] = (
    args.gitrepo or
    get_pref('GitRepo') or
    autopkglib.get_pref('MUNKI_REPO') or
    None
  )
  # Equivalent to --arc
  prefs_dict['use_arcanist'] = (
    bool(args.arc or get_pref('UseArcanist')) or
    False
  )
  return prefs_dict


def validate_preferences(prefs):
  """Return true if all preferences are set."""
  if VERBOSE:
    display_verbose(prefs)
  prefs_valid = True
  if not autopkglib.get_pref('RECIPE_OVERRIDE_DIRS'):
    timeprint('RECIPE_OVERRIDE_DIRS is missing or empty.')
    prefs_valid = False
  if not prefs['repo_dir']:
    timeprint(
      'repo_dir argument, GitRepo pref, or MUNKI_REPO is missing or empty.'
    )
    prefs_valid = False
  return prefs_valid


# Borrowed from munkicommon
def get_pref(pref_name, bundleid=BUNDLE_ID):
  """Get preference value for key from domain."""
  pref_value = CFPreferencesCopyAppValue(pref_name, bundleid)
  if isinstance(pref_value, NSDate):
      # convert NSDate/CFDates to strings
      pref_value = str(pref_value)
  return pref_value


def set_pref(pref_name, pref_value, bundleid=BUNDLE_ID):
  """Set a preference, writing it to ~/Library/Preferences/."""
  try:
    CFPreferencesSetValue(
      pref_name,
      pref_value,
      bundleid,
      kCFPreferencesCurrentUser,
      kCFPreferencesCurrentHost
    )
    CFPreferencesAppSynchronize(BUNDLE_ID)
  except BaseException:
    pass


# Git-related functions
def git_run(arglist):
  """Run git with the argument list."""
  gitcmd = [GIT]
  for arg in arglist:
    gitcmd.append(str(arg))
  # timeprint("Git cmd: %s" % gitcmd)
  results = run_cmd(gitcmd)
  if not results['success']:
    raise GitError("Git error: %s" % results['stderr'])
  return results['stdout']


def current_branch():
  """Return the name of the current git branch."""
  git_args = ['symbolic-ref', '--short', 'HEAD']
  return str(git_run(git_args).strip())


def branch_list():
  """Get the list of current git branches."""
  git_args = ['branch']
  branch_output = git_run(git_args).rstrip()
  if branch_output:
    return [x.strip().strip('* ') for x in branch_output.split('\n')]
  return []


def create_feature_branch(branch):
  """Create new feature branch."""
  # display_verbose("Calling create_feature_branch: %s" % branch)
  if current_branch() != 'master':
    # Switch to master first if we're not already there
    display_verbose('Switching to master')
    change_feature_branch('master')
  # Now create new branch
  display_verbose("Creating branch %s" % branch)
  change_feature_branch(branch, new=True)


def change_feature_branch(branch, new=False):
  """Swap to feature branch."""
  if USE_ARCANIST:
    arccmd = ['/usr/local/bin/arc', 'feature']
    arccmd.append(branch)
    results = run_cmd(arccmd)
    if not results['success']:
      raise BranchError(
        "Couldn't switch to '%s': %s" % (branch, results['stderr'])
      )
  else:
    gitcmd = ['checkout']
    if new:
      gitcmd.append('-b')
    gitcmd.append(branch)
    try:
      git_run(gitcmd)
    except GitError as e:
      raise BranchError(
        "Couldn't switch to '%s': %s" % (branch, e)
      )


def cleanup_branch(branch):
  """Remove feature branch."""
  # Swap back to 'master' first
  change_feature_branch('master')
  # Delete the branch
  gitcmd = ['branch', '-D', branch]
  results = git_run(gitcmd)
  display_verbose("Deleting branch %s: %s" % (branch, results))


def rename_branch_version(branch, version):
  """Rename a branch to include the version."""
  new_branch_name = branch + "-%s" % version
  if new_branch_name in branch_list():
    timeprint("Branch %s already exists" % new_branch_name)
    new_branch_name += '-2'
  gitcmd = ['branch', '-m', branch, new_branch_name]
  git_run(gitcmd)
  display_verbose("Renaming %s to %s" % (branch, new_branch_name))


def create_commit(imported_item):
  """Create git commit."""
  os.chdir(REPO_DIR)
  timeprint('Adding items...')
  gitaddcmd = ['add']
  gitaddcmd.append(REPO_DIR)
  git_run(gitaddcmd)
  # Create the commit
  timeprint('Creating commit...')
  gitcommitcmd = ['commit', '-m']
  message = "Updating %s to version %s" % (str(imported_item['name']),
                                           str(imported_item["version"]))
  gitcommitcmd.append(message)
  git_output = git_run(gitcommitcmd)


# Task functions
def create_task(task_title, task_description):
  """Create tasks for imported packages and receipes failures."""
  if DEV:
    timeprint('Dev mode, skipping task.')
    return
  # ****
  # Provide code here for filing tickets/tasks to your system
  # ****


def imported_task(imported_item):
  """File a task for a package being imported into Munki."""
  task_title = (
    "Package %s has been updated in Munki." % imported_item['name']
  )
  timeprint("Filing task: %s" % task_title)
  task_description = (
    "Catalogs: %s \n" % imported_item['catalogs'] +
    "Package Path: %s \n" % imported_item['pkg_repo_path'] +
    "Pkginfo Path: %s \n" % imported_item['pkginfo_path'] +
    "Version: %s" % str(imported_item['version'])
  )
  create_task(task_title, task_description)


def failed_task(failed_items):
  """File a task for a failed Autopkg recipe."""
  for item in failed_items:
    task_title = "Autopkg recipe %s failed to run." % item['recipe']
    timeprint("Failure: %s" % task_title)
    task_description = "Error: %s" % item['message']
    create_task(task_title, task_description)


# Middleware functions
def binary_middleware(imported_item):
  """Handle any middleware operations on the imported products."""
  # ****
  # This code is designed to handle anything you need/want to do
  # to the imported binaries as part of the commit process.
  # Upload to Amazon S3, or git-fat, etc.
  # ****


# Autopkg execution functions
def run_recipe(recipe, report_plist_path, pkg_path=None):
  """Execute autopkg on a recipe, creating report plist."""
  cmd = ['/usr/local/bin/autopkg', 'run', '-v']
  cmd.append(recipe)
  if pkg_path:
    cmd.append('-p')
    cmd.append(pkg_path)
  cmd.append('--report-plist')
  cmd.append(report_plist_path)
  run_live(cmd)
  # https://github.com/autopkg/autopkg/issues/296
  # Currently, AutoPkg returns the number of failed recipes when it executes
  # so we can't use return code to see if it faulted
  # results = run_live(cmd)
  # if results != 0:
  #  raise RunError("Error: %s failed: %s" % (recipe, results['stderr']))


def parse_report_plist(report_plist_path):
  """Parse the report plist path for a dict of the results."""
  imported_items = []
  failed_items = []
  report_data = FoundationPlist.readPlist(report_plist_path)
  if report_data['summary_results']:
    # This means something happened
    munki_results = report_data['summary_results'].get(
      'munki_importer_summary_result', {}
    )
    for imported_item in munki_results.get('data_rows', []):
      imported_items.append(imported_item)
  if report_data['failures']:
    # This means something went wrong
    for failed_item in report_data['failures']:
      # For each recipe that failed, file a task
      failed_items.append(failed_item)
  return {
    'imported': imported_items,
    'failed': failed_items
  }


def handle_recipe(recipe, pkg_path=None):
  """Handle the complete workflow of an autopkg recipe."""
  display_verbose("Handling %s" % recipe)
  if autopkglib.get_pref('RECIPE_REPO_DIR'):
    recipe_repo_dir = autopkglib.get_pref('RECIPE_REPO_DIR')
  else:
    recipe_repo_dir = os.path.expanduser('~/Library/AutoPkg/RecipeRepos')
  report_plist_path = os.path.join(
    os.path.dirname(recipe_repo_dir),
    'autopkg.plist'
  )
  # 1. Syncing is no longer implemented
  # 2. Parse recipe name for basic item name
  branchname = parse_recipe_name(recipe)
  # 3. Create feature branch
  create_feature_branch(branchname)
  # 4. Run autopkg for that recipe
  run_recipe(recipe, report_plist_path, pkg_path)
  # 5. Parse report plist
  run_results = parse_report_plist(report_plist_path)
  if not run_results['imported'] and not run_results['failed']:
    # Nothing happened
    cleanup_branch(branchname)
    return
  if run_results['failed']:
    # Item failed, so file a task
    failed_task(run_results['failed'])
    cleanup_branch(branchname)
    return
  if run_results['imported']:
    # Item succeeded, so continue.
    # 6. Run any binary-handling middleware
    binary_middleware(run_results['imported'][0])
    # 7. If any changes occurred, create git commit
    create_commit(run_results['imported'][0])
    # 8. Rename branch with version
    rename_branch_version(
      branchname,
      str(run_results['imported'][0]['version'])
    )
    # 9. File a task
    imported_task(run_results['imported'][0])
  # 10. Switch back to master
  change_feature_branch('master')


def parse_recipe_list(file_path):
  """Parse a recipe list from a file path. Supports JSON, YAML, or plist."""
  timeprint("Parsing recipe list")
  if not os.path.isfile(file_path):
    timeprint("No recipe list found at that path!")
    sys.exit(-1)
  recipe_list = []
  extension = os.path.splitext(file_path)[1]
  if extension == '.json':
    with open(file_path, 'rb') as f:
      recipe_list = json.load(f)
  elif extension in ('.yaml', '.yml') and YAML_INSTALLED:
    with open(file_path, 'rb') as f:
      recipe_list = yaml.load(f)
  elif extension == '.plist':
    recipe_list = FoundationPlist.readPlist(file_path)
  else:
    raise RunlistError
  display_verbose("Recipe list: %s" % recipe_list)
  return recipe_list


if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    description='Wrap AutoPkg with git support.')
  group = parser.add_mutually_exclusive_group()
  group.add_argument(
    '-l', '--list', help='Path to a plist, JSON, or YAML list of recipe names.'
  )
  group.add_argument(
    '-r', '--recipes', nargs='+',
    help='Recipes to run.'
  )
  parser.add_argument(
    '-v', '--verbose', action='store_true',
    help='Print verbose messages.'
  )
  parser.add_argument(
    '-g', '--gitrepo',
    help='Path to git repo. Defaults to MUNKI_REPO from Autopkg preferences.',
    default=autopkglib.get_pref('MUNKI_REPO')
  )
  parser.add_argument(
    '-a', '--arc', help='Use arcanist instead of git for branches.',
    action='store_true',
    default=False
  )
  parser.add_argument(
    '-d', '--dev', help='Dev mode - debug logging.',
    action='store_true',
    default=False
  )
  parser.add_argument(
    '-p', '--pkg', help=('Path to a pkg or dmg to provide to a recipe.\n'
                         'Ignored if you pass in more than once recipe to -r,'
                         ' or -l.'),
  )
  args = parser.parse_args()
  prefs_dict = read_preferences(args)
  # Validate that the specific settings we absolutely need are present
  VERBOSE = prefs_dict.get('verbosity', False)
  DEV = args.dev
  USE_ARCANIST = prefs_dict.get('use_arcanist', False)
  REPO_DIR = prefs_dict.get('repo_dir')
  passed_runlist = prefs_dict.get('runlist', [])
  runlist = []
  pkg_path = None
  if not validate_preferences(prefs_dict):
    sys.exit(-1)
  if args.recipes:
    # Use the passed-in recipes instead of prefs
    display_verbose('Using argument recipes: %s' % args.recipes)
    runlist = args.recipes
    if len(runlist) == 1:
      # Only consider -p arg if one recipe was passed
      if args.pkg:
        pkg_path = args.pkg
  elif passed_runlist:
    # Parse the list
    runlist = parse_recipe_list(passed_runlist)
  else:
    # No runlist nor recipes passed in
    timeprint('No runlist or recipes passed in! You must provide one.')
    parser.print_help()
    sys.exit(-1)
  timeprint("Beginning AutoPkg run...")
  # Switch to repo directory for git
  timeprint('Changing working directory to git repo...')
  os.chdir(REPO_DIR)
  # Run the recipe list
  for recipe in runlist:
    handle_recipe(recipe, pkg_path)
  timeprint("autopkg_runner.py execution complete.")
