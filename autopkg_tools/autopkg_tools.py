#!/usr/bin/env python2
"""Tools to manage the run of AutoPkg."""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import logging
import os

from cpe.pyexec.core import shell_tools
from cpe.pyexec.modules import FoundationPlist
from cpe.pyexec.modules import pref_tools
from cpe.pyexec.modules import scm_tools


GIT = '/opt/facebook/bin/git'
VERBOSE = 0
REPO_DIR = '/Users/Shared/autopkg'
USE_ARCANIST = False
DEV = False
AUTOPKG_BUNDLE_ID = 'com.github.autopkg'


class AutoPkgToolsError(Exception):
    """Base class for domain-specific exceptions."""


class AutoPkgToolsBranchError(AutoPkgToolsError):
    """Branch-related exceptions."""


class AutoPkgToolsRunError(AutoPkgToolsError):
    """AutoPkg Run exceptions."""


class AutoPkgToolsGitError(AutoPkgToolsError):
    """Git exceptions."""


class AutoPkgToolsResultsPlistError(AutoPkgToolsError):
    """Unable to read the results plist."""


class AutoPkgMunkiImportResult(object):
    """
    The results from successfully importing an item into Munki.

    This is a representation of a result of importing something into Munki.
    It contains the name of the imported item, the version, and the catalogs
    that it was imported into.

    Attributes:
        catalogs (list): List of strings of Munki catalogs item was imported
            into.
        name (str): Name of the imported item.
        path (str): Path of imported binary.
        version (str): Version value of the imported item.
    """
    __slots__ = (
        'catalogs',
        'name',
        'path',
        'version'
    )

    def __init__(self):
        self.catalogs = []  # list of strings
        self.name = None  # str
        self.path = None  # str
        self.version = None  # str

    def __str__(self):
        return str(self.name)

    def __format__(self):
        return str(self.name)

    def __repr__(self):
        return str(self.name)


class AutoPkgFailureResult(object):
    """
    The results from a failed AutoPkg recipe execution.

    This is a representation of a result of an AutoPkg recipe failing.
    It contains the message of the failure (typically the text of a traceback),
    and the recipe that failed.

    Attributes:
        message (str): Message of cause of failure.
        recipe (str): Recipe name that failed to execute.
    """
    __slots__ = (
        'message',
        'recipe',
    )

    def __init__(self):
        self.message = None  # str
        self.recipe = None  # str

    def __str__(self):
        return str(self.recipe)

    def __format__(self):
        return str(self.recipe)

    def __repr__(self):
        return str(self.recipe)


class AutoPkgRecipe(object):
    """
    An AutoPkg Recipe object that can be executed and parsed for results.

    The recipe contains two critical attributes - the full name, and the
    identifier. All other attributes are results from running it.

    The execution result contains more information - all
    items downloaded, imported into Munki, and failed executions.

    When using ContentHasher, we store the path to the hashfile for a given
    recipe, and a dictionary containing all hashes for that particular
    container (dmg, pkg, etc.).

    Expected usage:
        recipe = autopkg_tools.AutoPkgRecipe('Firefox.munki')
        recipe.run()


    Attributes:
        fullname (str): Full name of recipe.
        identifier (str): Identifier of recipe.
        downloaded_items (list): List of strings of path to downloaded items
        imported_items (list): List of strings of paths to downloaded items.
        failed_items (list): List of recipe names that failed.
        hashfile (str): Path to generated hash file from ContentHasher.
        hashes (dict): Dictionary of hashes for all files inside container.
        report_plist_path (str): Path to report plist.
    """
    def __init__(self, fullname):
        self.fullname = fullname  # str
        self.identifier = self.fullname.split('.munki')[0]  # str
        self.downloaded_items = []  # list of strings
        self.imported_items = []  # list of AutoPkgMunkiImportResult
        self.failed_items = []  # list of AutoPkgFailureResult
        self.hashfile = None  # path to the JSON file hashes
        self.hashes = {}  # dict of all hashed files from ContentHasher
        self.report_plist_path = os.path.join(
            os.path.dirname(get_autopkg_pref('CACHE_DIR')),
            'autopkg_report.plist'
        )

    def run(self, verbose=False):
        """Run this recipe."""
        logging.debug("AutoPkgRecipe::run")
        self.__run_recipe(self.fullname, verbose=verbose)
        self.parse_report_plist()

    def parse_report_plist(self, plist_path=None):
        """Parse the report plist path for results."""
        logging.debug("AutoPkgRecipe::parse_report_plist")
        report_plist_path = self.report_plist_path
        if plist_path:
            report_plist_path = plist_path
        try:
            report_data = FoundationPlist.readPlist(report_plist_path)
        except (FoundationPlist.NSPropertyListSerializationException, IOError):
            # Report plist is missing
            raise AutoPkgToolsResultsPlistError(
                "{} is missing".format(report_plist_path)
            )
        if report_data.get('summary_results', []):
            # Get a list of downloaded items
            self.__read_urldownloader_summary(report_data)
            logging.debug('Downloaded items: {}'.format(self.downloaded_items))
            # Get items imported into Munki
            self.__read_munki_importer_summary(report_data)
            logging.debug('Imported items: {}'.format(self.imported_items))
            # Get Content Hasher results if they're present
            self.__read_content_hasher_summary(report_data)
        if report_data.get('failures', []):
            # This means something went wrong
            self.__read_failure_summary(report_data)
            logging.warn('Failed items: {}'.format(self.failed_items))

    def __read_urldownloader_summary(self, plist):
        """Parse a list of all file paths downloaded by URLDownloader."""
        downloaded_items = []
        dl_results = plist['summary_results'].get(
            'url_downloader_summary_result', {}
        )
        for downloaded in dl_results.get('data_rows', []):
            downloaded_items.append(downloaded['download_path'])
        self.downloaded_items = downloaded_items

    def __read_munki_importer_summary(self, plist):
        """Parse a list of AutoPkgMunkiImportResults imported into Munki."""
        imported_items = []
        munki_results = plist['summary_results'].get(
            'munki_importer_summary_result', {}
        )
        for imported_item in munki_results.get('data_rows', []):
            item = AutoPkgMunkiImportResult()
            item.catalogs = imported_item['catalogs']
            item.name = imported_item['name']
            item.version = imported_item['version']
            item.path = imported_item['pkg_repo_path']
            imported_items.append(item)
        self.imported_items = imported_items

    def __read_content_hasher_summary(self, plist):
        """Parse the ContentHasher summary results."""
        hash_results = plist['summary_results'].get(
            'content_hasher_summary_result', {}
        )
        for hashed_item in hash_results.get('data_rows', []):
            # this will be the same for all
            self.hashfile = hashed_item['hashfile']
            # This will be a hash containing all files and hashes
            self.hashes = hashed_item['hash_contents']

    def __read_failure_summary(self, plist):
        """Parse a list of all recipes that failed to run."""
        failed_items = []
        for failed_item in plist['failures']:
            failure = AutoPkgFailureResult()
            failure.recipe = failed_item['recipe']
            failure.message = failed_item['message']
            failed_items.append(failure)
        self.failed_items = failed_items

    def __run_recipe(self, recipe, pkg_path=None, verbose=False):
        """Execute autopkg on a recipe, creating report plist."""
        cmd = ['/usr/local/bin/autopkg', 'run', '-v']
        cmd.append(recipe)
        if pkg_path:
            cmd.append('-p')
            cmd.append(pkg_path)
        # Always generate a content hash of anything uploaded to MSC
        cmd.append('--post')
        cmd.append('com.facebook.autopkg.shared/ContentHasher')
        # We want structured data for the report
        cmd.append('--report-plist')
        cmd.append(self.report_plist_path)
        loglevel = logging.DEBUG
        if verbose:
            loglevel = logging.INFO
        shell_tools.run_live(cmd, loglevel)


def get_autopkg_pref(key):
    """Get a preference key from AutoPkg's preferences."""
    return pref_tools.get_pref(key, AUTOPKG_BUNDLE_ID)


def parse_recipe_name(identifier):
    """Get the name of the recipe."""
    # All recipes are named 'Name.type'
    branch = identifier.split('.')[0]
    # Check to see if branch name already exists
    if branch in scm_tools.branch_list():
        # Avoid branch name collisions
        branch += '-copy'
    return branch
