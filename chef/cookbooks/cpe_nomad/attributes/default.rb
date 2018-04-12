#
# Cookbook Name:: cpe_nomad
# Attributes:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

default['cpe_nomad'] = {
  'install' => false,
  'uninstall' => false,
  'enable' => false,
  'configure' => false,
  'demobilize' => false,
  'pkg' => {
    'name' => 'nomad',
    'checksum' => nil,
    'receipt' => 'com.trusourcelabs.NoMAD',
    'version' => nil,
    'pkg_name' => nil,
    'pkg_url' => nil,
  },
  'launchagent' => {
    'program_arguments' => [
      '/Applications/NoMAD.app/Contents/MacOS/NoMAD',
    ],
    'run_at_load' => true,
    'keep_alive' => true,
    'limit_load_to_session_type' => 'Aqua',
    'type' => 'agent',
  },
  'prefs' => {
    'ADDomain' => nil, # String
    'AutoConfigure' => nil, # String
    'AutoRenewCert' => nil, # Integer
    'CaribouTime' => nil, # Bool
    'ChangePasswordCommand' => nil, # String
    'ChangePasswordOptions' => nil, # String
    'ChangePasswordType' => nil, # String
    'ConfigureChrome' => nil, # Bool
    'ConfigureChromeDomain' => nil, # String
    'DontMatchKerbPrefs' => nil, # Bool
    'DontShowWelcome' => nil, # Bool
    'DontShowWelcomeDefaultOn' => nil, # Bool
    'ExportableKey' => nil, # Bool
    'GetCertificateAutomatically' => nil, # Bool
    'GetHelpOptions' => nil, # String
    'GetHelpType' => nil, # String
    'HicFix' => nil, # Bool
    'HideExpiration' => nil, # Bool
    'HideExpirationMessage' => nil, # String
    'HideGetSoftware' => nil, # Bool
    'HideHelp' => nil, # Bool
    'HideLockScreen' => nil, # Bool
    'HidePrefs' => nil, # Bool
    'HideRenew' => nil, # Bool
    'HideSignOut' => nil, # Bool
    'HideQuit' => nil, # Bool
    'IconOff' => nil, # String
    'IconOffDark' => nil, # String
    'IconOn' => nil, # String
    'IconOnDark' => nil, # String
    'KerberosRealm' => nil, # String
    'KeychainItems' => nil, # Dictionary
    'LDAPAnonymous' => nil, # Bool
    'LDAPServerList' => nil, # String
    'LDAPOnly' => nil, # Bool
    'LDAPOverSSL' => nil, # Bool
    'LDAPType' => nil, # String
    'LocalPasswordSync' => nil, # Bool
    'LocalPasswordSyncDontSyncLocalUsers' => nil, # Array of Strings
    'LocalPasswordSyncDontSyncNetworkUsers' => nil, # Array of Strings
    'LocalPasswordSyncOnMatchOnly' => nil, # Bool
    'LoginItem' => nil, # Bool
    'MenuChangePassword' => nil, # String
    'MenuGetCertificate' => nil, # String
    'MenuHomeDirectory' => nil, # String
    'MenuGetHelp' => nil, # String
    'MenuGetSoftware' => nil, # String
    'MenuPasswordExpires' => nil, # String
    'MenuRenewTickets' => nil, # String
    'MenuUserName' => nil, # String
    'MenuWelcome' => nil, # String
    'MessageLocalSync' => nil, # String
    'MessageNotConnected' => nil, # String
    'MessagePasswordChangePolicy' => nil, # String
    'MessageUPCAlert' => nil, # String
    'PasswordExpireAlertTime' => nil, # Integer
    'PasswordExpireCustomAlert' => nil, # String
    'PasswordExpireCustomWarnTime' => nil, # Integer
    'PasswordExpireCustomAlertTime' => nil, # Integer
    'PasswordPolicy' => nil, # Dictionary
    'PersistExpiration' => nil, # Bool
    'RecursiveGroupLookup' => nil, # Bool
    'RenewTickets' => nil, # Bool
    'SecondsToRenew' => nil, # Integer
    'SelfServicePath' => nil, # String
    'ShowHome' => nil, # Bool
    'SignInCommand' => nil, # String
    'SignInWindowAlert' => nil, # Bool
    'SignInWindowAlertTime' => nil, # Integer
    'SignInWindowOnLaunch' => nil, # Bool
    'SignInWindowOnLaunchExclusions' => nil, # Array
    'SignOutCommand' => nil, # String
    'StateChangeAction' => nil, # String
    'Template' => nil, # String
    'TitleSignIn' => nil, # String
    'UPCAlert' => nil, # Bool
    'UPCAlertAction' => nil, # Bool
    'UseKeychain' => nil, # Bool
    'UseKeychainPrompt' => nil, # Bool
    'Verbose' => nil, # Bool
    'WifiNetworks' => nil, # String
    'X509CA' => nil, # String
  },
  'noload_prefs' => {
    'ADDomain' => nil, # String
    'createAdminUser' => nil, # Bool
    'DemobilizeUsers' => nil, # Bool
    'KeychainAddNoMAD' => nil, # Bool
    'KeychainCreate' => nil, # Bool
  },
  'actions_prefs' => {
    'Version' => nil, # Int
    'MenuIcon' => nil, # Bool
    'MenuText' => nil, # Bool
    'Actions' => nil, # Dictionary
  },
}
