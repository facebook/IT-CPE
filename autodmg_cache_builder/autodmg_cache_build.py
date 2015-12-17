#!/usr/bin/python

import argparse
import inspect
import json
import os
import shutil
import sys
import tempfile
import urllib2
import time

from autodmg_utility import pkgbuild, run, build_pkg, populate_ds_repo

current_frame = inspect.currentframe()
my_path = os.path.abspath(inspect.getfile(current_frame))
# Append munkilib to the Python path
sys.path.append('/usr/local/munki/munkilib')
try:
  import FoundationPlist as plistlib
except ImportError:
  print "Using plistlib"
  import plistlib
try:
  from munkicommon import MunkiLooseVersion, pref
  from updatecheck import makeCatalogDB
  from fetch import (getURLitemBasename, getResourceIfChangedAtomically,
                     MunkiDownloadError)
except ImportError as err:
  print "Something went wrong! %s" % err

MUNKI_URL = pref('SoftwareRepoURL')
MANIFESTS_URL = MUNKI_URL + '/manifests'
CATALOG_URL = MUNKI_URL + '/catalogs'
PKGS_URL = MUNKI_URL + '/pkgs'
ICONS_URL = MUNKI_URL + '/icons'
BASIC_AUTH = pref('AdditionalHttpHeaders')
CATALOG = {}
CACHE = '/tmp'


# download functions
def download_url_to_cache(url, cache, force=False):
  '''Takes a URL and downloads it to a local cache'''
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


# manifest functions
def get_manifest(manifest):
  '''Returns a plist dictionary of manifest data'''
  manifesturl = MANIFESTS_URL + '/' + urllib2.quote(manifest)
  manifestcache = os.path.join(CACHE, 'manifests')
  print "Considering manifest %s" % manifest
  changed = True
  try:
    changed = download_url_to_cache(manifesturl, manifestcache)
  except MunkiDownloadError as err:
    print >> sys.stderr, "Manifest download error: %s" % err
    if not os.path.isfile(manifestcache):
      # If there was a network error, and no cache, abort.
      sys.exit(-1)
  if not changed:
    print "No changes in manifest, using cache."
  return plistlib.readPlist(os.path.join(manifestcache, manifest))


def process_manifest_installs(manifest):
  '''Takes a manifest plist and returns a list of all installs from it.
      Recursively calls itself for includes'''
  install_list = list()
  for include in manifest.get('included_manifests', []):
    print "Found included manifest: %s" % include
    install_list += process_manifest_installs(get_manifest(include))
  # Done processing includes, now process installs
  for install in manifest.get('managed_installs', []):
    # Add this to the list of things to precache
    install_list.append(str(install))
  return install_list


def process_manifest_optionals(manifest):
  '''Takes a manifest plist and returns a list of all optional installs from it.
      Recursively calls itself for includes'''
  optional_list = list()
  for install in manifest.get('optional_installs', []):
    # Add this to the list of things to precache
    optional_list.append(str(install))
  return optional_list


# catalog functions
def get_catalog(catalog):
  '''Takes a catalog name and returns the whole catalog'''
  catalogurl = CATALOG_URL + '/' + urllib2.quote(catalog)
  catalogcache = os.path.join(CACHE, 'catalogs')
  print "Considering catalog %s" % catalog
  try:
    changed = download_url_to_cache(catalogurl, catalogcache)
  except MunkiDownloadError as err:
    print 'Could not retrieve catalog %s from server: %s' % (
      catalog, err)
    if not os.path.isfile(catalogcache):
      # If there was a network error, and no cache, abort.
      sys.exit(-1)
  if not changed:
    print "No changes in catalog, using cache."
  return plistlib.readPlist(os.path.join(catalogcache, catalog))


def get_catalogs(cataloglist):
  """Retrieves the catalogs from the server and populates our catalogs
  dictionary.
  """
  for catalogname in cataloglist:
    if catalogname not in CATALOG:
      try:
        catalog_data = get_catalog(catalogname)
      except IOError as err:
        print "Could not read catalog plist: %s" % err
      else:
          CATALOG[catalogname] = makeCatalogDB(catalog_data)


# item functions
# Based on updatecheck.py but modified for simpler use
def get_item_detail(name, cataloglist, vers=''):
  """Searches the catalogs in list for an item matching the given name.
  If no version is supplied, but the version is appended to the name
  ('TextWrangler--2.3.0.0.0') that version is used.
  If no version is given at all, the latest version is assumed.
  Returns a pkginfo item.
  """
  def compare_version_keys(a, b):
    """Internal comparison function for use in sorting"""
    return cmp(MunkiLooseVersion(b), MunkiLooseVersion(a))

  vers = 'latest'
  for catalogname in cataloglist:
    if catalogname not in CATALOG.keys():
      # in case the list refers to a non-existent catalog
      print "Non existent catalog"
      continue

    # is name in the catalog?
    if name in CATALOG[catalogname]['named']:
      itemsmatchingname = CATALOG[catalogname]['named'][name]
      indexlist = []
      if vers == 'latest':
        # order all our items, latest first
        versionlist = itemsmatchingname.keys()
        versionlist.sort(compare_version_keys)
        for versionkey in versionlist:
          indexlist.extend(itemsmatchingname[versionkey])

      elif vers in itemsmatchingname:
        # get the specific requested version
        indexlist = itemsmatchingname[vers]

      for index in indexlist:
        item = CATALOG[catalogname]['items'][index]
        # we have an item whose name and version matches the request.
        return item
  # if we got this far, we didn't find it.
  return None


def get_item_url(item, catalogs):
  '''Takes an item dict from get_item_detail() and returns the URL
      it can be downloaded from'''
  detail = get_item_detail(item, catalogs)
  if detail.get("installer_type") == "nopkg":
    return 'Nopkg: %s' % str(item)
  return PKGS_URL + '/' + urllib2.quote(detail["installer_item_location"])


def get_item_icon(item, catalogs):
  '''Takes an item from get_item_detail() and returns the URL
      the icon can be downloaded from'''
  detail = get_item_detail(item, catalogs)
  if detail.get("icon_name"):
    # if an icon name is found, there's an icon, go get it
    return ICONS_URL + '/' + urllib2.quote(detail["icon_name"])
  elif detail.get("icon_hash"):
    # if a hash is found, there's an icon
    return ICONS_URL + '/' + urllib2.quote(detail["name"] + ".png")


def get_item_hash(item, catalogs):
  '''Takes an item from get_item_detail() and returns the hash
      in the catalog'''
  detail = get_item_detail(item, catalogs)
  return detail.get('installer_item_hash')


# comparison function for catalogs/manifests
def is_newer_than_local(local_item, new_item):
  '''Compares a new catalog or manifest to the cached local file'''
  if os.path.isfile(local_item):
    local_plist = plistlib.readPlist(local_item)
    if not (local_plist == new_item):
      # They are not the same, therefore we are dirty
      print "Found changes."
      is_dirty = True
    # No changes, return false
    return False
  else:
    is_dirty = True
  # Write the changes to disk
  plistlib.writePlist(new_item, local_item)
  return is_dirty


# local management functions
def suppress_registration(cache_path):
  '''Builds a package to suppress Setup Assistant, returns path to it'''
  pkg_output_file = os.path.join(cache_path, 'suppress_registration.pkg')
  if not os.path.isfile(pkg_output_file):
    print "Building registration suppression package..."
    temp_dir = tempfile.mkdtemp(prefix='suppressreg', dir='/tmp')
    receipt = os.path.join(temp_dir, 'Library/Receipts')
    os.makedirs(receipt)
    open(os.path.join(receipt, '.SetupRegComplete'), 'a').close()
    vardb = os.path.join(temp_dir, 'private/var/db/')
    os.makedirs(vardb)
    open(os.path.join(vardb, '.AppleSetupDone'), 'a').close()
    pkgbuild(
      temp_dir,
      'com.facebook.cpe.suppress_registration',
      '1.0',
      pkg_output_file
    )
    shutil.rmtree(temp_dir, ignore_errors=True)
    return pkg_output_file
  # If we failed for some reason, return None
  return None


def create_local_path(path):
  '''Attempts to create a local folder. Returns True if succeeded.'''
  if not os.path.isdir(path):
    try:
      os.makedirs(path)
      return True
    except OSError as err:
      print "Failed to create %s: %s" % (path, err)
      return False
  return True


def prepare_local_paths(path_list):
  '''Sets up the necessary paths for the script'''
  fails = 0
  for path in path_list:
    if not create_local_path(path):
      fails += 1
  return fails


def cleanup_local_cache(item_list, local_path):
  '''Compares contents of local_path to an item list, removes
    all items in path that don't match'''
  for item in os.listdir(local_path):
    if item not in item_list:
      print "Removing: %s" % item
      os.remove(os.path.join(local_path, item))


def parse_extras(extras_file):
  '''Parse a JSON file for "exceptions" and "additions", returns
    a dict containing a list of both'''
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


def handle_dl(item_name, item_url, download_dir,
              force_download, exceptions=False):
  '''Downloads an item into the cache, returns
    True if downloaded'''
  target = 'cache'
  if exceptions:
    target = 'exceptions'
  try:
    print "Downloading into %s: %s" % (target, item_name)
    changed = download_url_to_cache(
      item_url,
      download_dir,
      force_download
    )
    if not changed:
      print "Found %s in %s" % (item_name, target)
    return True
  except MunkiDownloadError as err:
    print >> sys.stderr, "Download error for %s: %s" % (item_name, err)
  return False


def main():
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
    '-f', '--force', help='Force building a DMG.',
    action='store_true', default=False)
  parser.add_argument(
    '-l', '--logpath', help='Path to log file for AutoDMG.',
    default='/Users/Shared/AutoDMG_build.log')
  parser.add_argument(
    '-r', '--munkirepo', help='URL for Munki repo. Defaults to '
                              '"SoftwareRepoURL" from Munki prefs.')
  parser.add_argument(
    '-a', '--auth', help='Additional HTTP headers. Will read from '
                         '"AdditionalHttpHeaders" from Munki prefs.')
  parser.add_argument(
    '-s', '--source', help='Path to base OS installer.',
    default='/Applications/Install OS X Yosemite.app')
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
  parser.add_argument(
    '--keepsetup', help='Do NOT suppress Setup Assistant and registration. '
                        'Defaults to False.',
    action='store_true', default=False)
  args = parser.parse_args()

  if args.munkirepo:
    global MUNKI_URL
    global MANIFESTS_URL
    global CATALOG_URL
    global PKGS_URL
    global ICONS_URL
    MUNKI_URL = args.munkirepo
    MANIFESTS_URL = MUNKI_URL + '/manifests'
    CATALOG_URL = MUNKI_URL + '/catalogs'
    PKGS_URL = MUNKI_URL + '/pkgs'
    ICONS_URL = MUNKI_URL + '/icons'
  print "Using Munki repo: %s" % MUNKI_URL
  if args.auth:
    global BASIC_AUTH
    BASIC_AUTH = args.auth
  print "Additional headers: %s" % BASIC_AUTH
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
    'icons': os.path.join(CACHE, 'icons')
  }
  path_creation = prepare_local_paths(dir_struct.values())
  if path_creation > 0:
    print "Error setting up local cache directories."
    sys.exit(-1)

  # Populate the CATALOG global
  get_catalogs([args.catalog])
  # Populate a local manifest dict
  manifest = get_manifest(args.manifest)

  # Prior to downloading anything, populate the lists
  total_adds = 0
  total_excepts = 0
  additions_list = list()
  item_list = list()
  except_list = list()
  extras = {'additions': [], 'exceptions': []}
  if args.extras:
    # Extras now contains 'additions' and 'exceptions'
    extras = parse_extras(args.extras)
    # Check for additional packages
    if extras['additions']:
      print "Adding additional packages."
      for addition in extras['additions']:
        item_name = getURLitemBasename(addition)
        if "http" in addition:
          print "Considering %s" % addition
          if item_name.endswith('.mobileconfig'):
            # profiles must be downloaded into the 'exceptions' directory
            if handle_dl(item_name, addition, dir_struct['exceptions'],
                         args.download):
              total_excepts += 1
              except_list.append(item_name)
          else:
            if handle_dl(item_name, addition, dir_struct['additions'],
                         args.download):
              total_adds += 1
              additions_list.append(os.path.join(dir_struct['additions'],
                                    item_name))
        else:
          "Adding %s locally" % addition
          additions_list.append(addition)

  # Check for managed_install items and download them
  print "Checking for managed installs..."
  print "Exceptions list: %s" % extras['exceptions']
  install_list = process_manifest_installs(manifest)
  for item in install_list:
    itemurl = get_item_url(item, [args.catalog])
    item_basename = getURLitemBasename(itemurl)
    print "Looking at: %s" % item_basename
    if 'Nopkg' in itemurl:
      print "Nopkg found: %s" % item
    elif itemurl.endswith('.mobileconfig'):
      # Try to download the profile into the exceptions directory
      # Increment the exceptions total, and add it to the exceptions list
      if handle_dl(item, itemurl, dir_struct['exceptions'],
                   args.download, exceptions=True):
        total_excepts += 1
        except_list.append(urllib2.unquote(item_basename))
    elif any(x in item_basename for x in extras['exceptions']):
      # Try to download the exception into the exceptions directory
      # Increment the exceptions total, and add it to the exceptions list
      if handle_dl(item, itemurl, dir_struct['exceptions'],
                   args.download, exceptions=True):
        total_excepts += 1
        except_list.append(urllib2.unquote(item_basename))
    else:
      # Add it to the item list
      # Increment the additions total
      if handle_dl(item, itemurl, dir_struct['downloads'],
                   args.download):
        total_adds += 1
        item_list.append(urllib2.unquote(item_basename))

  # Clean up cache of items we don't recognize
  cleanup_local_cache(item_list, dir_struct['downloads'])
  cleanup_local_cache(except_list, dir_struct['exceptions'])

  # Icon handling
  pkg_output_file = os.path.join(CACHE, 'munki_icons.pkg')
  if not args.noicons:
    print "Checking for icons..."
    # Check for optional_install items and download icons
    install_list = process_manifest_optionals(manifest)
    total_changes = 0
    for item in install_list:
      itemicon = get_item_icon(item, [args.catalog])
      if handle_dl(item, itemicon, dir_struct['icons'], args.download):
        total_changes += 1
    # Build a package of optional Munki icons, so we don't need to cache
    if (not total_changes == 0) or not os.path.isfile(pkg_output_file):
      # We downloaded at least one icon, rebuild the package
      success = build_pkg(
        dir_struct['icons'],
        'munki_icons',
        'com.facebook.cpe.munki_icons',
        '/Library/Managed Installs/icons',
        CACHE,
        'Creating the icon package.'
      )
      if success:
        total_adds += 1
    else:
      print "No new icons, using existing icon package."
    # Add the icon package to the additional packages list for the template.
    if os.path.isfile(pkg_output_file):
      additions_list.extend([pkg_output_file])

  # Build the package of exceptions
  pkg_output_file = os.path.join(CACHE, 'munki_cache.pkg')
  if total_excepts > 0 or not os.path.isfile(pkg_output_file):
    success = build_pkg(
      dir_struct['exceptions'],
      'munki_cache',
      'com.facebook.cpe.munki_exceptions',
      '/Library/Managed Installs/Cache',
      CACHE,
      'Building exceptions package'
    )
    if success:
      total_adds += 1
  else:
    print "No new exceptions, using existing exceptions package."
  # Add the icon package to the additional packages list for the template.
  if os.path.isfile(pkg_output_file):
    additions_list.extend([pkg_output_file])

  # Suppress the Setup Assistant
  if not args.keepsetup:
    registration_pkg = suppress_registration(CACHE)
    if registration_pkg:
      additions_list.extend([registration_pkg])

  loglevel = str(args.loglevel)

  total = total_adds + total_excepts
  dmg_output_path = os.path.join(CACHE, args.output)
  if not args.force and os.path.isfile(dmg_output_path) and not total:
    # If we didn't make any changes, the DMG already exists, and we're not
    # forcing, stop here.
    print "No changes to manifest or catalog, DMG exists. Stopping."
    print time.strftime("%c")
    sys.exit(0)

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

  if extras['additions']:
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

  # Now kick off the AutoDMG build
  sys.stdout.flush()
  print "Building disk image..."
  if os.path.isfile(dmg_output_path):
    os.remove(dmg_output_path)
  cmd = autodmg_cmd + [
    '-L', loglevel,
    '-l', args.logpath,
    'build', templatepath,
    '--download-updates',
    '-o', dmg_output_path]
  print "Full command: %s" % cmd
  run(cmd)

  # Check the Deploystudio masters to see if this image already exists
  sys.stdout.flush()
  if args.dsrepo:
    populate_ds_repo(dmg_output_path, args.dsrepo)

  print "Ending run."
  print time.strftime("%c")

if __name__ == '__main__':
  main()
