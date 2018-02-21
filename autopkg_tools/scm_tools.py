#!/usr/bin/env python2

from __future__ import absolute_import
from __future__ import division
from __future__ import unicode_literals
from __future__ import print_function

import logging
import os

from cpe.pyexec.core import shell_tools

if shell_tools.is_mac():
    GIT = '/opt/facebook/bin/git'
    ARC = '/opt/facebook/bin/arc'
elif shell_tools.is_linux():
    GIT = '/usr/bin/git'
else:
    GIT = 'C:\Program Files\Git\cmd\git.exe'


class SCMGitException(Exception):
    """Raise if a generic git error occurs."""


class SCMGitBranchException(Exception):
    """Raise if a branch-related git error occurs."""


def change_feature_branch(branch, use_arcanist=False):
    """Change feature branch with git or arc."""
    if use_arcanist:
        arc_change_feature_branch(branch)
    else:
        git_change_feature_branch(branch)


# Git-related functions
def git_run(arglist):
    """Run git with the argument list."""
    if not isinstance(arglist, list):
        raise TypeError('Argument list must be an array')
    gitcmd = [GIT]
    gitcmd.extend(arglist)
    logging.debug(gitcmd)
    results = shell_tools.run_subp(gitcmd)
    if not results['success']:
        raise SCMGitException("Git error: {}".format(results['stderr']))
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


def create_feature_branch(branch, use_arcanist=False):
    """Create new feature branch."""
    if current_branch() != 'master':
        # Switching to master first helps avoid issues with arc
        # where it may want to stack the commits on each other
        logging.info('Switching to master')
        change_feature_branch('master', use_arcanist)
    change_feature_branch(branch, use_arcanist)


def git_change_feature_branch(branch):
    """Use git to change feature branches."""
    gitcmd = ['checkout']
    logging.debug('Switching to branch {}'.format(branch))
    try:
        git_run(gitcmd + [branch])
    except SCMGitException:
        logging.debug('Creating branch {}'.format(branch))
        # Branch may not exist, so try to create it
        gitcmd.extend(['-b', branch])
        try:
            git_run(gitcmd)
        except SCMGitBranchException() as ex:
            raise SCMGitBranchException(
                "Couldn't switch to '{}': {}".format(branch, ex))


def cleanup_branch(branch):
    """Remove feature branch."""
    change_feature_branch('master')
    # Delete the branch
    gitcmd = ['branch', '-D', branch]
    output = git_run(gitcmd)
    logging.info("Deleting branch {}: {}".format(branch, output))


def rename_branch_version(branch, version):
    """Rename a branch to include the version."""
    new_branch_name = branch + "-{}".format(version)
    if new_branch_name in branch_list():
        logging.debug("Branch {} already exists".format(new_branch_name))
        new_branch_name += '-2'
    gitcmd = ['branch', '-m', branch, new_branch_name]
    git_run(gitcmd)
    logging.debug("Renaming {} to {}".format(branch, new_branch_name))
    return new_branch_name


def add_items(folder):
    """Add items in folder to git staging area."""
    os.chdir(folder)
    logging.debug('Switched to staging folder, adding items to git')
    gitaddcmd = ['add', folder]
    output = git_run(gitaddcmd)
    logging.debug(output)


def create_commit(repo_dir, message):
    """Create git commit."""
    add_items(repo_dir)
    # Create the commit
    logging.info('Creating commit...')
    gitcommitcmd = ['commit', '-m']
    gitcommitcmd.append(message)
    output = git_run(gitcommitcmd)
    logging.debug(output)


def pull():
    """Run a git pull."""
    gitcmd = ['pull']
    output = git_run(gitcmd)
    logging.debug(output)


def push(arglist=[]):
    """Run a git push with args."""
    gitcmd = ['push']
    gitcmd.extend(arglist)
    output = git_run(gitcmd)
    logging.debug(output)


# arcanist-related features
def arc_change_feature_branch(branch):
    """Use arc to change feature branches."""
    arccmd = [ARC, 'feature']
    arccmd.append(branch)
    results = shell_tools.run_subp(arccmd)
    if not results['success']:
        raise SCMGitBranchException(
            "Couldn't switch to '{}': {}".format(
                branch, results['stderr']))
