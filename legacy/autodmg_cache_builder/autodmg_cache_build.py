#!/usr/bin/python
# Copyright (c) Facebook, Inc. and its affiliates.
"""Build thick images with AutoDMG and Munki.

With a given manifest and set of catalogs, parse all managed_installs and
incorporate them into the image.
"""

from __future__ import print_function
import argparse
import json
import os
import re
import shutil
import sys
import time
import urllib2

from autodmg_utility import run, build_pkg, populate_ds_repo
import autodmg_org

try:
    import FoundationPlist as plistlib
except ImportError:
    print("Using plistlib")
    import plistlib

try:
    import munkilib.display as display
    import munkilib.fetch as fetch
    import munkilib.prefs as prefs
    import munkilib.updatecheck.catalogs as catalogs
    import munkilib.updatecheck.manifestutils as manifestutils
    import munkilib.updatecheck.download as download
except ImportError as err:
    print("Something went wrong! %s" % err)


MUNKI_URL = prefs.pref('SoftwareRepoURL')
PKGS_URL = MUNKI_URL + '/pkgs'
BASIC_AUTH = prefs.pref('AdditionalHttpHeaders')
CACHE = '/tmp'


# download functions
def download_url_to_cache(url, cache, force=False):
    """Take a URL and downloads it to a local cache."""
    cache_path = os.path.join(
        cache,
        urllib2.unquote(download.get_url_basename(url))
    )
    custom_headers = ['']
    if BASIC_AUTH:
        # custom_headers = ['Authorization: Basic %s' % BASIC_AUTH]
        custom_headers = BASIC_AUTH
    if force:
        return fetch.getResourceIfChangedAtomically(
            url, cache_path,
            custom_headers=custom_headers,
            resume=True,
            expected_hash='no')
    return fetch.getResourceIfChangedAtomically(
        url, cache_path, custom_headers=custom_headers)


def handle_dl(item_name, item_url, download_dir, force_download):
    """Download an item into the cache, returns True if downloaded."""
    try:
        print("Downloading into %s: %s" % (download_dir, item_name))
        changed = download_url_to_cache(
            item_url,
            download_dir,
            force_download
        )
        if not changed:
            print("Found in cache")
        return True
    except fetch.DownloadError as err:
        print("Download error for %s: %s" % (item_name, err), file=sys.stderr)
    return False


# manifest functions
def process_manifest_for_key(manifest, manifest_key, parentcatalogs=None):
    """
    Process keys in manifests to get the lists of items to install and remove.

    Can be recursive if manifests include other manifests.
    Probably doesn't handle circular manifest references well.

    manifest can be a path to a manifest file or a dictionary object.
    """
    if isinstance(manifest, basestring):  # NOQA
        display.display_debug1(
            "** Processing manifest %s for %s" %
            (os.path.basename(manifest), manifest_key))
        manifestdata = manifestutils.get_manifest_data(manifest)
    else:
        manifestdata = manifest
        manifest = 'embedded manifest'

    cataloglist = manifestdata.get('catalogs')
    if cataloglist:
        catalogs.get_catalogs(cataloglist)
    elif parentcatalogs:
        cataloglist = parentcatalogs

    if not cataloglist:
        display.display_warning('Manifest %s has no catalogs', manifest)
        return

    for item in manifestdata.get('included_manifests', []):
        nestedmanifestpath = manifestutils.get_manifest(item)
        if not nestedmanifestpath:
            raise manifestutils.ManifestException
        process_manifest_for_key(nestedmanifestpath, manifest_key, cataloglist)
    return (cataloglist, manifestdata.get(manifest_key, []))


def obtain_manifest(manifest):
    """Download and process the manifest from the server."""
    # Get manifest from server first
    manifestpath = manifestutils.get_primary_manifest('image')
    # Parse manifest for managed_installs
    cataloglist = []
    managed_installs = []
    (cataloglist, managed_installs) = process_manifest_for_key(
        manifestpath, 'managed_installs')
    return (cataloglist, managed_installs)


# item functions
# Based on updatecheck.py but modified for simpler use
def get_item_url(item):
    """Take an item dict, return the URL it can be downloaded from."""
    return PKGS_URL + '/' + urllib2.quote(item["installer_item_location"])


def handle_icons(itemlist):
    """Download icons and build the package."""
    print("Downloading icons.")
    pkg_output_file = os.path.join(CACHE, 'munki_icons.pkg')
    # Set the local directory to the AutoDMG cache
    old_managed = prefs.pref('ManagedInstallDir')
    prefs.set_pref('ManagedInstallDir', CACHE)
    # Downloads all icons into the icon directory in the Munki cache
    download.download_icons(itemlist)
    # Put the actual Munki cache dir back
    prefs.set_pref('ManagedInstallDir', old_managed)
    # Build a package of optional Munki icons, so we don't need to cache
    success = build_pkg(
        os.path.join(CACHE, 'icons'),
        'munki_icons',
        'com.facebook.cpe.munki_icons',
        '/Library/Managed Installs/icons',
        CACHE,
        'Creating the icon package.'
    )
    # Add the icon package to the additional packages list for the template.
    if success:
        return pkg_output_file
    else:
        print("Failed to build icon package!", file=sys.stderr)
        return None


def handle_custom():
    """Download custom resources and build the package."""
    print("Downloading Munki client resources.")
    # Set the local directory to the AutoDMG cache
    old_managed = prefs.pref('ManagedInstallDir')
    prefs.set_pref('ManagedInstallDir', CACHE)
    # Downloads client resources into the AutoDMG cache
    download.download_client_resources()
    # Put the actual Munki cache dir back
    prefs.set_pref('ManagedInstallDir', old_managed)
    resource_dir = os.path.join(
        CACHE, 'client_resources')
    resource_file = os.path.join(resource_dir, 'custom.zip')
    if os.path.isfile(resource_file):
            # Client Resources are stored in
            # /Library/Managed Installs/client_resources/custom.zip
        destination_path = '/Library/Managed Installs/client_resources'
        pkg_output_file = os.path.join(CACHE, 'munki_custom.pkg')
        success = build_pkg(
            resource_dir,
            'munki_custom',
            'com.facebook.cpe.munki_custom',
            destination_path,
            CACHE,
            'Creating the Munki custom resources package.'
        )
        if success:
            return pkg_output_file
        else:
            print(
                "Failed to build Munki custom resources package!",
                file=sys.stderr
            )
            return None


def gather_install_list(manifest):
    """Gather the list of install items."""
    # First, swap out for our cache dir
    old_managed = prefs.pref('ManagedInstallDir')
    prefs.set_pref('ManagedInstallDir', CACHE)
    # Process the manifest for managed_installs
    (cataloglist, managed_installs) = obtain_manifest(manifest)
    install_list = []
    for item in managed_installs:
        print('Processing %s' % item)
        detail = catalogs.get_item_detail(item, cataloglist)
        if detail:
            install_list.append(detail)
    # Put the actual Munki cache dir back
    prefs.set_pref('ManagedInstallDir', old_managed)
    return install_list


def build_exceptions(cache_dir):
    """Build a package for each exception."""
    exceptions_pkg_list = []
    exceptions_dir = os.path.join(cache_dir, 'exceptions')
    exceptions_pkgs_dir = os.path.join(cache_dir, 'exceptions_pkgs')
    # Empty out existing exceptions packages first, to avoid cruft
    for file in os.listdir(exceptions_pkgs_dir):
        os.unlink(os.path.join(exceptions_pkgs_dir, file))
    counter = 1
    tmp_cache_dir = '/tmp/individ_except/Library/Managed Installs/Cache'
    try:
        os.makedirs(tmp_cache_dir)
    except OSError:
        # Path likely exists
        pass
    # Now begin our building
    for exception in os.listdir(exceptions_dir):
        split_name = re.split('_|-|\s', exception)[0]
        output_name = "munki_cache_%s-%s" % (split_name, str(counter))
        receipt_name = os.path.splitext(exception)[0]
        counter += 1
        # Copy each one to a temporary location
        shutil.copy2(
            os.path.join(cache_dir, 'exceptions', exception),
            tmp_cache_dir
        )
        output_exception_pkg = build_pkg(
            tmp_cache_dir,
            output_name,
            'com.facebook.cpe.munki_exceptions.%s' % receipt_name,
            '/Library/Managed Installs/Cache',
            exceptions_pkgs_dir,
            'Building exception pkg for %s' % exception
        )
        if output_exception_pkg:
            exceptions_pkg_list.append(output_exception_pkg)
        if not output_exception_pkg:
            print("Failed to build exceptions package for %s!" % exception)
        # Delete the copied file
        os.unlink(os.path.join(tmp_cache_dir, exception))
    return exceptions_pkg_list


def create_local_path(path):
    """Attempt to create a local folder. Returns True if succeeded."""
    if not os.path.isdir(path):
        try:
            os.makedirs(path)
            return True
        except OSError as err:
            print("Failed to create %s: %s" % (path, err))
            return False
    return True


def prepare_local_paths(path_list):
    """Set up the necessary paths for the script."""
    fails = 0
    for path in path_list:
        if not create_local_path(path):
            fails += 1
    return fails


def cleanup_local_cache(item_list, local_path):
    """Remove items from local cache that aren't needed."""
    for item in os.listdir(local_path):
        if item not in item_list:
            print("Removing: %s" % item)
            os.remove(os.path.join(local_path, item))


def parse_extras(extras_file):
    """Parse a JSON file for "exceptions" and "additions".

    Returns a dict containing a list of both.
    """
    parsed = ''
    extras = {'exceptions': [], 'additions': []}
    try:
        with open(extras_file, 'rb') as thefile:
            print("Parsing extras file...")
            parsed = json.load(thefile)
    except IOError as err:
        print("Error parsing extras file: %s" % err)
    # Check for exceptions
    extras['exceptions'] = parsed.get("exceptions_list", [])
    if extras['exceptions']:
        print("Found exceptions.")
    # Check for additions
    extras['additions'] = parsed.get("additions_list", [])
    if extras['additions']:
        print("Found additions.")
    return extras


def handle_extras(
    extras_file,
    exceptions_path,
    additions_path,
    force,
    exceptions,
    except_list,
    additions_list
):
    """Handle downloading and sorting the except/add file."""
    extras = parse_extras(extras_file)
    # Check for additional packages
    if extras['additions']:
        print("Adding additional packages.")
        for addition in extras['additions']:
            item_name = download.get_url_basename(addition)
            if "http" in addition:
                print("Considering %s" % addition)
                if item_name.endswith('.mobileconfig'):
                    # profiles must be downloaded into the 'exceptions' dir
                    if handle_dl(item_name, addition, exceptions_path, force):
                        except_list.append(item_name)
                else:
                    if handle_dl(item_name, addition, additions_path, force):
                        additions_list.append(os.path.join(
                            additions_path,
                            item_name)
                        )
            else:
                "Adding %s locally" % addition
                additions_list.append(addition)
    if extras['exceptions']:
        for exception in extras['exceptions']:
            exceptions.append(exception)


def process_managed_installs(
    install_list,
    exceptions,
    except_list,
    item_list,
    exceptions_path,
    download_path,
    force
):
    """Download managed_installs."""
    print("Checking for managed installs...")
    print("Exceptions list: %s" % exceptions)
    for item in install_list:
        print("Looking at: %s" % item['name'])
        if item['name'] in exceptions:
            print("Adding to exceptions list.")
            exception = True
        elif 'installer_type' not in item:
            # Assume it's a package
            if (
                'postinstall_script',
                'preinstall_script',
                'installcheck_script'
            ) in item:
                # We shouldn't try to do anything with Munki scripts
                exception = True
            exception = False
        elif item['installer_type'] == 'nopkg':
            # Obviously we don't attempt to handle these
            print("Nopkg found, skipping.")
            continue
        elif item['installer_type'] == 'profile':
            # Profiles go into the 'exceptions' dir automatically
            print("Profile found, adding to exceptions.")
            exception = True
        elif item['installer_type'] == 'copy_from_dmg':
            exception = False
            if (
                len(item['items_to_copy']) != 1 or
                item['items_to_copy'][0]['destination_path'] != '/Applications'
            ):
                # Only copy_from_dmgs that have single items going
                # into /Applications are supported
                print("Complex copy_from_dmg found, adding to exceptions.")
                exception = True
        else:
            # It's probably something Adobe related
            exception = True
        itemurl = get_item_url(item)
        item_basename = download.get_url_basename(itemurl)
        if exception:
            # Try to download the exception into the exceptions directory
            # Add it to the exceptions list
            if handle_dl(item_basename, itemurl, exceptions_path, force):
                except_list.append(urllib2.unquote(item_basename))
        else:
            # Add it to the item list
            if handle_dl(item_basename, itemurl, download_path, force):
                item_list.append(urllib2.unquote(item_basename))


def wait_for_network():
    """Wait until network access is up."""
    # Wait up to 180 seconds for scutil dynamic store to register DNS
    cmd = [
        '/usr/sbin/scutil',
        '-w', 'State:/Network/Global/DNS',
        '-t', '180'
    ]
    if run(cmd) != 0:
        print("Network did not come up after 3 minutes. Exiting!")
        sys.exit(1)


def main():
    """Main function."""
    wait_for_network()
    if not os.path.exists('/Applications/AutoDMG.app/Contents/MacOS/AutoDMG'):
        print("AutoDMG not at expected path in /Applications, quitting!")
        sys.exit(1)
    parser = argparse.ArgumentParser(
        description='Built a precached AutoDMG image.')
    parser.add_argument(
        '-m', '--manifest', help='Manifest name. Defaults to "prod".',
        default='prod')
    parser.add_argument(
        '-o', '--output', help='Path to DMG to create.',
        default='AutoDMG_full.hfs.dmg')
    parser.add_argument(
        '--cache', help=(
            'Path to local cache to store files. '
            'Defaults to "/Library/AutoDMG"'),
        default='/Library/AutoDMG')
    parser.add_argument(
        '-d', '--download', help='Force a redownload of all files.',
        action='store_true', default=False)
    parser.add_argument(
        '-l', '--logpath', help='Path to log files for AutoDMG.',
        default='/Library/AutoDMG/logs/')
    parser.add_argument(
        '-s', '--source', help='Path to base OS installer.',
        default='/Applications/Install OS X El Capitan.app')
    parser.add_argument(
        '-n', '--volumename', help=(
            'Name of volume after imaging. '
            'Defaults to "Macintosh HD."'),
        default='Macintosh HD')
    parser.add_argument(
        '-S', '--volumesize', help=(
            'Size of volume after imaging. '
            'Defaults to 120'),
        default=120)
    parser.add_argument(
        '--loglevel', help='Set loglevel between 1 and 7. Defaults to 6.',
        choices=range(1, 8), type=int, default=6)
    parser.add_argument(
        '--dsrepo', help='Path to DeployStudio repo. ')
    parser.add_argument(
        '--noicons', help="Don't cache icons.",
        action='store_true', default=False)
    parser.add_argument(
        '-u', '--update', help='Update the profiles plist.',
        action='store_true', default=False)
    parser.add_argument(
        '--extras', help=(
            'Path to JSON file containing additions '
            ' and exceptions lists.')
    )
    args = parser.parse_args()

    print("Using Munki repo: %s" % MUNKI_URL)
    global CACHE
    CACHE = args.cache

    print(time.strftime("%c"))
    print("Starting run...")
    # Create the local cache directories
    dir_struct = {
        'additions': os.path.join(CACHE, 'additions'),
        'catalogs': os.path.join(CACHE, 'catalogs'),
        'downloads': os.path.join(CACHE, 'downloads'),
        'exceptions': os.path.join(CACHE, 'exceptions'),
        'exceptions_pkgs': os.path.join(CACHE, 'exceptions_pkgs'),
        'manifests': os.path.join(CACHE, 'manifests'),
        'icons': os.path.join(CACHE, 'icons'),
        'logs': os.path.join(CACHE, 'logs'),
        'client_resources': os.path.join(CACHE, 'client_resources'),
    }
    path_creation = prepare_local_paths(dir_struct.values())
    if path_creation > 0:
        print("Error setting up local cache directories.")
        sys.exit(-1)

    # Populate the list of installs based on the manifest
    install_list = gather_install_list(args.manifest)

    # Prior to downloading anything, populate the other lists
    additions_list = list()
    item_list = list()
    except_list = list()
    exceptions = list()
    # exceptions[] is a list of exceptions specified by the extras file
    # except_list[] is a list of files downloaded into the exceptions dir
    if args.extras:
        # Additions are downloaded & added to the additions_list
        # Exceptions are added to the exceptions list,
        # Downloaded exceptions are added to the except_list list.
        handle_extras(
            args.extras,
            dir_struct['exceptions'],
            dir_struct['additions'],
            args.download,
            exceptions,
            except_list,
            additions_list
        )

    # Check for managed_install items and download them
    process_managed_installs(
        install_list,
        exceptions,
        except_list,
        item_list,
        dir_struct['exceptions'],
        dir_struct['downloads'],
        args.download
    )

    # Clean up cache of items we don't recognize
    print("Cleaning up downloads folder...")
    cleanup_local_cache(item_list, dir_struct['downloads'])
    print("Cleaning up exceptions folder...")
    cleanup_local_cache(except_list, dir_struct['exceptions'])

    # Icon handling
    if not args.noicons:
        # Download all icons from the catalogs used by the manifest
        catalog_item_list = []
        for catalog in os.listdir(dir_struct['catalogs']):
            catalog_item_list += plistlib.readPlist(
                os.path.join(dir_struct['catalogs'], catalog)
            )
        icon_pkg_file = handle_icons(catalog_item_list)
    if icon_pkg_file:
        additions_list.extend([icon_pkg_file])

    # Munki custom resources handling
    custom_pkg_file = handle_custom()
    if custom_pkg_file:
        additions_list.extend([custom_pkg_file])

    # Build each exception into its own package
    sys.stdout.flush()
    exceptions_pkg_list = build_exceptions(CACHE)
    additions_list.extend(exceptions_pkg_list)

    loglevel = str(args.loglevel)

    # Run any extra code or package builds
    sys.stdout.flush()
    pkg_list = autodmg_org.run_unique_code(args)
    additions_list.extend(pkg_list)

    # Now that cache is downloaded, let's add it to the AutoDMG template.
    print("Creating AutoDMG-full.adtmpl.")
    templatepath = os.path.join(CACHE, 'AutoDMG-full.adtmpl')

    plist = dict()
    plist["ApplyUpdates"] = True
    plist["SourcePath"] = args.source
    plist["TemplateFormat"] = "1.0"
    plist["VolumeName"] = args.volumename
    plist["VolumeSize"] = args.volumesize
    plist["AdditionalPackages"] = [
        os.path.join(
            dir_struct['downloads'], f
        ) for f in os.listdir(
            dir_struct['downloads']
        ) if (not f == '.DS_Store') and (f not in additions_list)
    ]

    if additions_list:
        plist["AdditionalPackages"].extend(additions_list)

    # Complete the AutoDMG-full.adtmpl template
    plistlib.writePlist(plist, templatepath)
    autodmg_cmd = [
        '/Applications/AutoDMG.app/Contents/MacOS/AutoDMG'
    ]
    if os.getuid() == 0:
        # We are running as root
        print("Running as root.")
        autodmg_cmd.append('--root')
    if args.update:
        # Update the profiles plist too
        print("Updating UpdateProfiles.plist...")
        cmd = autodmg_cmd + ['update']
        run(cmd)

    # Clean up cache of items we don't recognize
    print("Cleaning up downloads folder...")
    cleanup_local_cache(item_list, dir_struct['downloads'])
    print("Cleaning up exceptions folder...")
    cleanup_local_cache(except_list, dir_struct['exceptions'])

    logfile = os.path.join(args.logpath, 'build.log')
    # Now kick off the AutoDMG build
    dmg_output_path = os.path.join(CACHE, args.output)
    sys.stdout.flush()
    print("Building disk image...")
    if os.path.isfile(dmg_output_path):
        os.remove(dmg_output_path)
    cmd = autodmg_cmd + [
        '-L', loglevel,
        '-l', logfile,
        'build', templatepath,
        '--download-updates',
        '-o', dmg_output_path]
    print("Full command: %s" % cmd)
    run(cmd)
    if not os.path.isfile(dmg_output_path):
        print("Failed to create disk image!", file=sys.stderr)
        sys.exit(1)

    sys.stdout.flush()
    if args.dsrepo:
        # Check the Deploystudio masters to see if this image already exists
        populate_ds_repo(dmg_output_path, args.dsrepo)

    print("Ending run.")
    print(time.strftime("%c"))


if __name__ == '__main__':
    main()
