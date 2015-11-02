#!/usr/bin/python
#
# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

import subprocess
import sys
import os
import inspect
import glob
import time

current_frame = inspect.currentframe()
my_path = os.path.abspath(inspect.getfile(current_frame))
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

# Change the list of recipes to run here:
RECIPES = [
  'AdobeFlashPlayer.munki',
  'Firefox.munki',
  'GoogleChrome.munki',
  'OracleJava8JDK.munki',
]


def create_task(task_title, task_description):
  """
  create_task()

  Creates tasks for imported packages and receipes failures.
  """
  # Fill in your own code here for sending an email, filing a ticket/task,
  # or otherwise generating a notification.
  return


def get_recipe_parents(recipe, searchlist):
  '''Gets a list of all recipes in the parent chain, including the original
     recipe. Recipe can be either a name or a path'''
  parent_list = list()
  # use searchlist to search for info
  cmd = ['/usr/local/bin/autopkg', 'info']
  for searchdir in searchlist:
    cmd.extend(['-d', searchdir])
  cmd.append(recipe)
  proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  (iout, ierr) = proc.communicate()
  for line in iout.split('\n'):
    if 'Recipe file path' in line:
      # Add itself to list of paths
      if 'override' in line:
        # If this is an override, prepend it
        parent_list.append('override-' + line.split(':')[1].lstrip())
      else:
        parent_list.append(line.split(':')[1].lstrip())
    if 'Parent' in line:
      # print 'Parent recipe found: %s' % line.split(':')[1].lstrip()
      parent_list.extend(
        get_recipe_parents(line.split(':')[1].lstrip(), searchlist))
      break
  return parent_list


def run_cmd(cmd):
  '''Runs a command and prints the output'''
  proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
  )
  (out, err) = proc.communicate()
  if err:
      # print "Error: %s" % err
      return err
  return out


def change_feature_branch(branch):
  '''Switches current git branch to branch'''
  if branch != 'master':
    # we're creating a feature branch, so switch to master first
    arccmd = ['/usr/bin/git', 'checkout']
    newbranch = 'master'
    arccmd.append(newbranch)
    print run_cmd(arccmd)
  # Now switch to / create feature branch
  arccmd = ['/usr/bin/git', 'branch', '-b']
  arccmd.append(branch)
  return run_cmd(arccmd)


def git_run(arglist):
  '''Runs git with the argument list'''
  gitcmd = ['/usr/bin/git']
  for arg in arglist:
    gitcmd.append(str(arg))
  print "Git cmd: %s" % gitcmd
  return run_cmd(gitcmd)


def rsync(arglist):
  '''Runs rsync -Phav with the argument list'''
  rcmd = [
    '/usr/bin/rsync',
    '-Phav',
    '--exclude=.git*',
    '--exclude=*.md'
  ]
  for arg in arglist:
    rcmd.append(str(arg))
  return run_cmd(rcmd)


def create_parent_list(recipes):
  '''Returns a list of all parent recipes used by recipe list'''
  # build search list
  searchlist = glob.glob(os.path.join(
    autopkglib.get_pref('RECIPE_REPO_DIR'), "*"))
  # print "Recipe search list: %s" % searchlist
  parent_list = list()
  for recipe in recipes:
    parent_list.extend(get_recipe_parents(recipe, searchlist))
  # parent_list now has all recipes used to run those above
  # print "Total parent list: %s" % parent_list
  return parent_list


def create_destinations_list(dest_dir, parent_list):
  '''Returns a list of all destination folders used by each recipe name'''
  dirlist = list()
  if not os.path.isdir(dest_dir):
    # Create the destination folder first, if necessary
    os.mkdir(dest_dir)
  # Build the list of parent directories
  for path in parent_list:
    if path.startswith('override-'):
      # skip overrides, they're already in the overrides directory
      continue
    else:
      parentdir = os.path.dirname(path)
      if parentdir not in dirlist:
        dirlist.append(parentdir)
  # print "Dir list: %s" % dirlist
  return dirlist


def autopkg_run(recipe, report_plist_path):
  '''Runs an autopkg recipe and creates a report_plist'''
  cmd = ['/usr/local/bin/autopkg', 'run', '-vvvv']
  cmd.append(recipe)
  # Add MakeCatalogs.munki so that we don't keep importing copies
  # if AutoPkg runs again before someone makes catalogs
  cmd.append('MakeCatalogs.munki')
  cmd.append('--report-plist')
  cmd.append(report_plist_path)
  print "Running AutoPkg with the following recipes: %s" % recipe
  # print "Cmd: %s" % cmd
  print run_cmd(cmd)


def file_munki_task(imported_item):
  '''File a task for a package being imported into Munki'''
  task_title = (
    'Package %s has been updated in Munki.' % imported_item["name"]
  )
  print "Filing task: %s" % task_title
  task_description = (
    'Catalogs: %s \n' % imported_item["catalogs"] +
    'Package Path: %s \n' % imported_item["pkg_repo_path"] +
    'Pkginfo Path: %s \n' % imported_item["pkginfo_path"] +
    'Version: %s' % str(imported_item["version"])
  )
  create_task(task_title, task_description)


def create_commit(imported_item):
  '''Creates a new feature branch, commits the changes,
     switches back to master'''
  # print "Changing location to %s" % autopkglib.get_pref('MUNKI_REPO')
  os.chdir(autopkglib.get_pref('MUNKI_REPO'))
  # Now, we need to create a feature branch
  print "Creating feature branch."
  branch = '%s-%s' % (str(imported_item['name']),
                      str(imported_item["version"]))
  print change_feature_branch(branch)
  # Now add all items to git staging
  print "Adding items..."
  gitaddcmd = ['add', '--all']
  gitaddcmd.append(autopkglib.get_pref("MUNKI_REPO"))
  print git_run(gitaddcmd)
  # Create the commit
  print "Creating commit..."
  gitcommitcmd = ['commit', '-m']
  message = "Updating %s to version %s" % (str(imported_item['name']),
                                           str(imported_item["version"]))
  gitcommitcmd.append(message)
  print git_run(gitcommitcmd)
  # Switch back to master
  branch = 'master'
  print change_feature_branch(branch)


def file_failed_task(failed_item):
  '''File a task for a recipe failing to run'''
  task_title = 'Autopkg recipe %s failed to run.' % failed_item["recipe"]
  print "Failure: %s" % task_title
  task_description = 'Error: %s' % failed_item["message"]
  create_task(task_title, task_description)


def rsync_run(source, destination):
  '''Runs rsync from source to destination'''
  rsync_args = [
    source,
    destination
  ]
  print rsync(rsync_args)


if __name__ == '__main__':
  print "Starting: %s" % time.ctime()
  print "Beginning autopkg_runner.py execution..."
  recipe_failures = {}
  report_plist_path = os.path.join(
    os.path.dirname(autopkglib.get_pref('RECIPE_REPO_DIR')),
    'autopkg.plist'
  )

  # Build the list of all parent recipes we'll need to run these recipes
  parent_list = create_parent_list(RECIPES)
  dest_dir = os.path.expanduser(autopkglib.get_pref('RECIPE_SEARCH_DIRS')[1])
  # print "dest_dir: %s" % dest_dir
  print "Creating destination directories..."
  # Gather a list of all the directory names for the recipes to be copied into
  dirlist = create_destinations_list(dest_dir, parent_list)
  print "Syncing recipes to recipes folder."
  # Special case: makes sure autopkg/recipes/Munki/MakeCatalogs.munki joins in
  autopkg_recipes = os.path.join(
    autopkglib.get_pref('RECIPE_REPO_DIR'),
    'com.github.autopkg.autopkg-recipes',
  )
  munki_dir = os.path.join(autopkg_recipes, 'Munki')
  rsync_run(munki_dir, dest_dir + "/")
  # Rsync each of the parent directories over to the autopkg recipes directory
  for parentdir in dirlist:
    rsync_run(parentdir, dest_dir + "/")

  # Run all recipes
  for recipe in RECIPES:
    # Run each recipe individually, storing a report plist
    autopkg_run(recipe, report_plist_path)
    print "Parsing plist."
    # Now parse output - get a dict of the plist
    reportData = FoundationPlist.readPlist(report_plist_path)

    if reportData['summary_results']:
      # This means something happened
      munkiResults = reportData['summary_results'].get(
        'munki_importer_summary_result', {}
      )
      for imported_item in munkiResults.get("data_rows", []):
        # Create a git commit for each imported item
        create_commit(imported_item)
        # For each item that imports a new package, file a task
        file_munki_task(imported_item)

    if reportData['failures']:
      # This means something went wrong
      for failed_item in reportData['failures']:
        # For each recipe that failed, file a task
        file_failed_task(failed_item)

  # Now clean up after ourselves and delete the report_plist
  os.remove(report_plist_path)
  print "autopkg_runner.py execution complete."
  print "Ending: %s" % time.ctime()
