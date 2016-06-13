#!/usr/bin/python
"""Build thick images with AutoDMG and Munki.

With a given manifest and set of catalogs, parse all managed_installs and
incorporate them into the image.
"""

import argparse
import json
import os
import sys
import urllib2
import time

from autodmg_utility import run, build_pkg, populate_ds_repo
import autodmg_org

# Append munkilib to the Python path
with open('/private/etc/paths.d/munki', 'rb') as f:
  munkipath = f.read().strip()
sys.path.append(os.path.join(munkipath, 'munkilib'))
try:
  import FoundationPlist as plistlib
except ImportError:
  print "Using plistlib"
  import plistlib
try:
  from munkicommon import pref, getsha256hash
  import updatecheck
  from fetch import (getURLitemBasename, getResourceIfChangedAtomically,
                     MunkiDownloadError, writeCachedChecksum,
                     getxattr, XATTR_SHA)
  import keychain
except ImportError as err:
  print "Something went wrong! %s" % err

MUNKI_URL = pref('SoftwareRepoURL')
PKGS_URL = MUNKI_URL + '/pkgs'
ICONS_URL = MUNKI_URL + '/icons'
BASIC_AUTH = pref('AdditionalHttpHeaders')
CACHE = '/tmp'


# download functions
def download_url_to_cache(url, cache, force=False):
  """Take a URL and downloads it to a local cache."""
  cache_path = os.path.join(cache, urllib2.unquote(getURLitemBasename(url)))
  custom_headers = ['']
  if BASIC_AUTH:
    # custom_headers = ['Authorization: Basic %s' % BASIC_AUTH]
    custom_headers = BASIC_AUTH
  if force:
    return getResourceIfChangedAtomically(
      url, cache_path,
      custom_headers=custom_headers,
      resume=True,
      expected_hash='no')
  return getResourceIfChangedAtomically(
    url, cache_path, custom_headers=custom_headers)


def handle_dl(item_name, item_url, download_dir,
              force_download):
  """Download an item into the cache, returns True if downloaded."""
  try:
    print "Downloading into %s: %s" % (download_dir, item_name)
    changed = download_url_to_cache(
      item_url,
      download_dir,
      force_download
    )
    if not changed:
      print "Found in cache"
    return True
  except MunkiDownloadError as err:
    print >> sys.stderr, "Download error for %s: %s" % (item_name, err)
  return False


# item functions
# Based on updatecheck.py but modified for simpler use
def get_item_url(item):
  """Take an item dict, return the URL it can be downloaded from."""
  return PKGS_URL + '/' + urllib2.quote(item["installer_item_location"])


def download_icons(item_list, icon_dir):
  """Download icons for items in the list.

  Based on updatecheck.py, modified.
  Copied from
  https://github.com/munki/munki/blob/master/code/client/munkilib/updatecheck.py#L2824

  Attempts to download icons (actually png files) for items in
     item_list
  """
  icon_list = []
  icon_known_exts = ['.bmp', '.gif', '.icns', '.jpg', '.jpeg', '.png', '.psd',
                     '.tga', '.tif', '.tiff', '.yuv']
  icon_base_url = (pref('IconURL') or
                   pref('SoftwareRepoURL') + '/icons/')
  icon_base_url = icon_base_url.rstrip('/') + '/'
  for item in item_list:
    icon_name = item.get('icon_name') or item['name']
    pkginfo_icon_hash = item.get('icon_hash')
    if not os.path.splitext(icon_name)[1] in icon_known_exts:
      icon_name += '.png'
    icon_list.append(icon_name)
    icon_url = icon_base_url + urllib2.quote(icon_name.encode('UTF-8'))
    icon_path = os.path.join(icon_dir, icon_name)
    if os.path.isfile(icon_path):
      xattr_hash = getxattr(icon_path, XATTR_SHA)
      if not xattr_hash:
        xattr_hash = getsha256hash(icon_path)
        writeCachedChecksum(icon_path, xattr_hash)
    else:
      xattr_hash = 'nonexistent'
    icon_subdir = os.path.dirname(icon_path)
    if not os.path.exists(icon_subdir):
      try:
          os.makedirs(icon_subdir, 0755)
      except OSError, err:
          print 'Could not create %s' % icon_subdir
          continue
    custom_headers = ['']
    if BASIC_AUTH:
      # custom_headers = ['Authorization: Basic %s' % BASIC_AUTH]
      custom_headers = BASIC_AUTH
    if pkginfo_icon_hash != xattr_hash:
      item_name = item.get('display_name') or item['name']
      message = 'Getting icon %s for %s...' % (icon_name, item_name)
      try:
        dummy_value = getResourceIfChangedAtomically(
          icon_url, icon_path, custom_headers=custom_headers, message=message)
      except MunkiDownloadError, err:
        print ('Could not retrieve icon %s from the server: %s',
               icon_name, err)
      else:
        if os.path.isfile(icon_path):
            writeCachedChecksum(icon_path)


def handle_icons(icon_dir, installinfo):
  """Download icons and build the package."""
  print "Downloading icons."
  pkg_output_file = os.path.join(CACHE, 'munki_icons.pkg')
  icon_list = installinfo['optional_installs']
  icon_list.extend(installinfo['managed_installs'])
  icon_list.extend(installinfo['removals'])
  # Downloads all icons into the icon directory in the Munki cache
  download_icons(icon_list, icon_dir)

  # Build a package of optional Munki icons, so we don't need to cache
  success = build_pkg(
    icon_dir,
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
    print >> sys.stderr, "Failed to build icon package!"
    return None


def handle_custom(custom_dir):
  """Download custom resources and build the package."""
  print "Downloading Munki client resources."
  updatecheck.download_client_resources()
  # Client Resoures are stored in
  #   /Library/Managed Installs/client_resources/custom.zip
  resource_dir = os.path.join(
    pref('ManagedInstallDir'), 'client_resources')
  resource_file = os.path.join(resource_dir, 'custom.zip')
  if os.path.isfile(resource_file):
    destination_path = custom_dir
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
      print >> sys.stderr, "Failed to build Munki custom resources package!"
      return None


def create_local_path(path):
  """Attempt to create a local folder. Returns True if succeeded."""
  if not os.path.isdir(path):
    try:
      os.makedirs(path)
      return True
    except OSError as err:
      print "Failed to create %s: %s" % (path, err)
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
      print "Removing: %s" % item
      os.remove(os.path.join(local_path, item))


def parse_extras(extras_file):
  """Parse a JSON file for "exceptions" and "additions".

  Returns a dict containing a list of both.
  """
  parsed = ''
  extras = {'exceptions': [], 'additions': []}
  try:
    with open(extras_file, 'rb') as thefile:
      print "Parsing extras file..."
      parsed = json.load(thefile)
  except IOError as err:
    print "Error parsing extras file: %s" % err
  # Check for exceptions
  extras['exceptions'] = parsed.get("exceptions_list", [])
  if extras['exceptions']:
    print "Found exceptions."
  # Check for additions
  extras['additions'] = parsed.get("additions_list", [])
  if extras['additions']:
    print "Found additions."
  return extras


def handle_extras(extras_file, exceptions_path, additions_path,
                  force, exceptions, except_list, additions_list):
  """Handle downloading and sorting the except/add file."""
  extras = parse_extras(extras_file)
  # Check for additional packages
  if extras['additions']:
    print "Adding additional packages."
    for addition in extras['additions']:
      item_name = getURLitemBasename(addition)
      if "http" in addition:
        print "Considering %s" % addition
        if item_name.endswith('.mobileconfig'):
          # profiles must be downloaded into the 'exceptions' directory
          if handle_dl(item_name, addition, exceptions_path,
                       force):
            except_list.append(item_name)
        else:
          if handle_dl(item_name, addition, additions_path,
                       force):
            additions_list.append(os.path.join(additions_path,
                                  item_name))
      else:
        "Adding %s locally" % addition
        additions_list.append(addition)
  if extras['exceptions']:
    for exception in extras['exceptions']:
      exceptions.append(exception)


def process_managed_installs(install_list, exceptions, except_list, item_list,
                             exceptions_path, download_path, force):
  """Download managed_installs."""
  print "Checking for managed installs..."
  print "Exceptions list: %s" % exceptions
  for item in install_list:
    print "Looking at: %s" % item['name']
    if item['name'] in exceptions:
      print "Adding to exceptions list."
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
      print "Nopkg found, skipping."
      continue
    elif item['installer_type'] == 'profile':
      # Profiles go into the 'exceptions' dir automatically
      print "Profile found, adding to exceptions."
      exception = True
    elif item['installer_type'] == 'copy_from_dmg':
      exception = False
      if (
        len(item['items_to_copy']) != 1 or
        item['items_to_copy'][0]['destination_path'] != '/Applications'
      ):
        # Only copy_from_dmgs that have single items going
        # into /Applications are supported
        print "Complex copy_from_dmg found, adding to exceptions."
        exception = True
    else:
      # It's probably something Adobe related
      exception = True
    itemurl = get_item_url(item)
    item_basename = getURLitemBasename(itemurl)
    if exception:
      # Try to download the exception into the exceptions directory
      # Add it to the exceptions list
      if handle_dl(item_basename, itemurl, exceptions_path,
                   force):
        except_list.append(urllib2.unquote(item_basename))
    else:
      # Add it to the item list
      if handle_dl(item_basename, itemurl, download_path,
                   force):
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
    print "Network did not come up after 3 minutes. Exiting!"
    sys.exit(1)


def main():
  """Main function."""
  wait_for_network()
  if not os.path.exists('/Applications/AutoDMG.app/Contents/MacOS/AutoDMG'):
    print "AutoDMG not at expected path in /Applications, quitting!"
    sys.exit(1)
  parser = argparse.ArgumentParser(
    description='Built a precached AutoDMG image.')
  parser.add_argument(
    '-c', '--catalog', help='Catalog name. Defaults to "prod".',
    default='prod')
  parser.add_argument(
    '-m', '--manifest', help='Manifest name. Defaults to "prod".',
    default='prod')
  parser.add_argument(
    '-o', '--output', help='Path to DMG to create.',
    default='AutoDMG_full.hfs.dmg')
  parser.add_argument(
    '--cache', help='Path to local cache to store files.'
                    ' Defaults to "/Library/AutoDMG"',
    default='/Library/AutoDMG')
  parser.add_argument(
    '-d', '--download', help='Force a redownload of all files.',
    action='store_true', default=False)
  parser.add_argument(
    '-l', '--logpath', help='Path to log files for AutoDMG.',
    default='/Library/AutoDMG/logs/')
  parser.add_argument(
    '--custom', help='Path to place custom resources. Defaults to '
                     '/Library/Managed Installs/client_resources/.',
    default='/Library/Managed Installs/client_resources/')
  parser.add_argument(
    '-s', '--source', help='Path to base OS installer.',
    default='/Applications/Install OS X El Capitan.app')
  parser.add_argument(
    '-v', '--volumename', help='Name of volume after imaging. '
                               'Defaults to "Macintosh HD."',
    default='Macintosh HD')
  parser.add_argument(
    '--loglevel', help='Set loglevel between 1 and 7. Defaults to 6.',
    choices=range(1, 8), default=6)
  parser.add_argument(
    '--dsrepo', help='Path to DeployStudio repo. ')
  parser.add_argument(
    '--noicons', help="Don't cache icons.",
    action='store_true', default=False)
  parser.add_argument(
    '-u', '--update', help='Update the profiles plist.',
    action='store_true', default=False)
  parser.add_argument(
    '--extras', help='Path to JSON file containing additions '
                     ' and exceptions lists.')
  args = parser.parse_args()

  print "Using Munki repo: %s" % MUNKI_URL
  global CACHE
  CACHE = args.cache

  if "https" in MUNKI_URL and not BASIC_AUTH:
    print >> sys.stderr, "Error: HTTPS was used but no auth provided."
    sys.exit(2)

  print time.strftime("%c")
  print "Starting run..."
  # Create the local cache directories
  dir_struct = {
    'additions': os.path.join(CACHE, 'additions'),
    'catalogs': os.path.join(CACHE, 'catalogs'),
    'downloads': os.path.join(CACHE, 'downloads'),
    'exceptions': os.path.join(CACHE, 'exceptions'),
    'manifests': os.path.join(CACHE, 'manifests'),
    'icons': os.path.join(CACHE, 'icons'),
    'logs': os.path.join(CACHE, 'logs')
  }
  path_creation = prepare_local_paths(dir_struct.values())
  if path_creation > 0:
    print "Error setting up local cache directories."
    sys.exit(-1)

  # These are necessary to populate the globals used in updatecheck
  keychain_obj = keychain.MunkiKeychain()
  manifestpath = updatecheck.getPrimaryManifest(args.manifest)
  updatecheck.getPrimaryManifestCatalogs(args.manifest)
  updatecheck.getCatalogs([args.catalog])

  installinfo = {}
  installinfo['processed_installs'] = []
  installinfo['processed_uninstalls'] = []
  installinfo['managed_updates'] = []
  installinfo['optional_installs'] = []
  installinfo['managed_installs'] = []
  installinfo['removals'] = []
  updatecheck.processManifestForKey(manifestpath, 'managed_installs',
                                    installinfo)
  # installinfo['managed_installs'] now contains a list of all managed_installs
  install_list = []
  for item in installinfo['managed_installs']:
    detail = updatecheck.getItemDetail(item['name'], [args.catalog])
    if detail:
      install_list.append(detail)

  # Prior to downloading anything, populate the lists
  additions_list = list()
  item_list = list()
  except_list = list()
  exceptions = list()
  # exceptions[] is a list of exceptions specified by the extras file
  # except_list is a list of files downloaded into the exceptions dir
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
  process_managed_installs(install_list, exceptions,
                           except_list, item_list,
                           dir_struct['exceptions'],
                           dir_struct['downloads'],
                           args.download)

  # Icon handling
  if not args.noicons:
    # Get icons for Managed Updates, Optional Installs and removals
    updatecheck.processManifestForKey(manifestpath, 'managed_updates',
                                    installinfo)
    updatecheck.processManifestForKey(manifestpath, 'managed_uninstalls',
                                    installinfo)
    updatecheck.processManifestForKey(manifestpath, 'optional_installs',
                                    installinfo)
    icon_pkg_file = handle_icons(dir_struct['icons'], installinfo)
  if icon_pkg_file:
    additions_list.extend([icon_pkg_file])

  # Munki custom resources handling
  custom_pkg_file = handle_custom(args.custom)
  if custom_pkg_file:
    additions_list.extend([custom_pkg_file])

  # Clean up cache of items we don't recognize
  cleanup_local_cache(item_list, dir_struct['downloads'])
  cleanup_local_cache(except_list, dir_struct['exceptions'])

  # Build the package of exceptions, if any
  if except_list:
    pkg_output_file = os.path.join(CACHE, 'munki_cache.pkg')
    success = build_pkg(
      dir_struct['exceptions'],
      'munki_cache',
      'com.facebook.cpe.munki_exceptions',
      '/Library/Managed Installs/Cache',
      CACHE,
      'Building exceptions package'
    )
    if success:
      additions_list.extend([pkg_output_file])
    else:
      print "Failed to build exceptions package!"

  loglevel = str(args.loglevel)

  # Run any extra code or package builds
  sys.stdout.flush()
  pkg_list = autodmg_org.run_unique_code(args)
  additions_list.extend(pkg_list)

  # Now that cache is downloaded, let's add it to the AutoDMG template.
  print "Creating AutoDMG-full.adtmpl."
  templatepath = os.path.join(CACHE, 'AutoDMG-full.adtmpl')

  plist = dict()
  plist["ApplyUpdates"] = True
  plist["SourcePath"] = args.source
  plist["TemplateFormat"] = "1.0"
  plist["VolumeName"] = args.volumename
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
    print "Running as root."
    autodmg_cmd.append('--root')
  if args.update:
    # Update the profiles plist too
    print "Updating UpdateProfiles.plist..."
    cmd = autodmg_cmd + ['update']
    run(cmd)

  logfile = os.path.join(args.logpath, 'build.log')
  # Now kick off the AutoDMG build
  dmg_output_path = os.path.join(CACHE, args.output)
  sys.stdout.flush()
  print "Building disk image..."
  if os.path.isfile(dmg_output_path):
    os.remove(dmg_output_path)
  cmd = autodmg_cmd + [
    '-L', loglevel,
    '-l', logfile,
    'build', templatepath,
    '--download-updates',
    '-o', dmg_output_path]
  print "Full command: %s" % cmd
  run(cmd)
  if not os.path.isfile(dmg_output_path):
    print >> sys.stderr, "Failed to create disk image!"
    sys.exit(1)

  # Check the Deploystudio masters to see if this image already exists
  sys.stdout.flush()
  if args.dsrepo:
    populate_ds_repo(dmg_output_path, args.dsrepo)

  print "Ending run."
  print time.strftime("%c")

if __name__ == '__main__':
  main()
