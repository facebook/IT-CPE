# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_munki
# Attributes:: 2.8.0.2810
#
# Copyright 2015-present Facebook
#
# All rights reserved - Do Not Redistribute
#
return unless node.macosx?
munki = {}
munki['2.8.0.2810'] = {}

munki['2.8.0.2810']['munki_core_version'] = '2.8.0.2810'
munki['2.8.0.2810']['munki_core_folders'] = [
  'Library/Managed Installs',
  'Library/Managed Installs/Cache',
  'Library/Managed Installs/catalogs',
  'Library/Managed Installs/manifests',
  'private/etc/paths.d',
  'usr/local/munki',
  'usr/local/munki/munkilib',
]
munki['2.8.0.2810']['munki_core_files'] = [
  'private/etc/paths.d/munki',
  'usr/local/munki/launchapp',
  'usr/local/munki/logouthelper',
  'usr/local/munki/managedsoftwareupdate',
  'usr/local/munki/ptyexec',
  'usr/local/munki/supervisor',
  'usr/local/munki/munkilib/__init__.py',
  'usr/local/munki/munkilib/adobeutils.py',
  'usr/local/munki/munkilib/appleupdates.py',
  'usr/local/munki/munkilib/fetch.py',
  'usr/local/munki/munkilib/FoundationPlist.py',
  'usr/local/munki/munkilib/gurl.py',
  'usr/local/munki/munkilib/iconutils.py',
  'usr/local/munki/munkilib/installer.py',
  'usr/local/munki/munkilib/keychain.py',
  'usr/local/munki/munkilib/launchd.py',
  'usr/local/munki/munkilib/munkicommon.py',
  'usr/local/munki/munkilib/munkistatus.py',
  'usr/local/munki/munkilib/powermgr.py',
  'usr/local/munki/munkilib/profiles.py',
  'usr/local/munki/munkilib/removepackages.py',
  'usr/local/munki/munkilib/updatecheck.py',
  'usr/local/munki/munkilib/utils.py',
  'usr/local/munki/munkilib/version.plist',
]
munki['2.8.0.2810']['munki_admin_version'] = '2.8.0.2810'
munki['2.8.0.2810']['munki_admin_folders'] = [
  'private/etc/paths.d',
  'usr/local/munki',
]
munki['2.8.0.2810']['munki_admin_files'] = [
  'private/etc/paths.d/munki',
  'usr/local/munki/iconimporter',
  'usr/local/munki/makecatalogs',
  'usr/local/munki/makepkginfo',
  'usr/local/munki/manifestutil',
  'usr/local/munki/munkiimport',
]
munki['2.8.0.2810']['munki_launchd_version'] = '2.0.0.1969'
munki['2.8.0.2810']['munki_launchd_folders'] = [
  'Library/LaunchAgents',
  'Library/LaunchDaemons',
]
munki['2.8.0.2810']['munki_launcha_files'] = [
  'com.googlecode.munki.ManagedSoftwareCenter.plist',
  'com.googlecode.munki.managedsoftwareupdate-loginwindow.plist',
  'com.googlecode.munki.MunkiStatus.plist',
]
munki['2.8.0.2810']['munki_ld_files'] = [
  'com.googlecode.munki.logouthelper.plist',
  'com.googlecode.munki.managedsoftwareupdate-check.plist',
  'com.googlecode.munki.managedsoftwareupdate-install.plist',
  'com.googlecode.munki.managedsoftwareupdate-manualcheck.plist',
]
munki['2.8.0.2810']['munki_app_version'] = '4.2.2759'
munki['2.8.0.2810']['munki_app_checksum'] =
  '0feb9567930ce815cb4785e4b3ad1a7aa7a47eee2a2657a41f2acc9cef72c209'
default['cpe_munki']['2.8.0.2810'] = munki['2.8.0.2810']
