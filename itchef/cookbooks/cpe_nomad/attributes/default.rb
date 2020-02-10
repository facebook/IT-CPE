#
# Cookbook Name:: cpe_nomad
# Attributes:: default
#
# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['cpe_nomad'] = {
  'install' => false,
  'uninstall' => false,
  'enable' => false,
  'configure' => false,
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
    'CleanCerts' => nil, # Bool
    'ConfigureChrome' => nil, # Bool
    'ConfigureChromeDomain' => nil, # String
    'CustomLDAPAttributes' => nil, # Array
    'DontMatchKerbPrefs' => nil, # Bool
    'DontShowWelcome' => nil, # Bool
    'DontShowWelcomeDefaultOn' => nil, # Bool
    'ExportableKey' => nil, # Bool
    'GetCertificateAutomatically' => nil, # Bool
    'GetHelpOptions' => nil, # String
    'GetHelpType' => nil, # String
    'HicFix' => nil, # Bool
    'HideAbout' => nil, # Bool
    'HideExpiration' => nil, # Bool
    'HideExpirationMessage' => nil, # String
    'HideGetSoftware' => nil, # Bool
    'HideHelp' => nil, # Bool
    'HideLockScreen' => nil, # Bool
    'HidePrefs' => nil, # Bool
    'HideRenew' => nil, # Bool
    'HideSignOut' => nil, # Bool
    'HideQuit' => nil, # Bool
    'HomeAppendDomain' => nil, # Bool
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
    'LightsOutIKnowWhatImDoing' => nil, # Bool
    'LocalPasswordSync' => nil, # Bool
    'LocalPasswordSyncDontSyncLocalUsers' => nil, # Array of Strings
    'LocalPasswordSyncDontSyncNetworkUsers' => nil, # Array of Strings
    'LocalPasswordSyncOnMatchOnly' => nil, # Bool
    'LoginItem' => nil, # Bool
    'MenuAbout' => nil, # String
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
    'MountSharesWithFinder' => nil, # Bool
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
    'UserSwitch' => nil, # Bool
    'Verbose' => nil, # Bool
    'WifiNetworks' => nil, # String
    'X509CA' => nil, # String
  },
  'login' => {
    'install' => false,
    'enable' => false,
    'pkg' => {
      'name' => 'nomadloginad',
      'checksum' => nil,
      'receipt' => 'menu.nomad.login.ad',
      'version' => nil,
      'pkg_name' => nil,
      'pkg_url' => nil,
    },
    'prefs' => {
      'ADDomain' => nil, # String
      'AdditionalADDomains' => nil, # String or Array of Strings
      'BackgroundImage' => nil, # String
      'BackgroundImageAlpha' => nil, # Int
      'createAdminUser' => nil, # Bool
      'CreateAdminIfGroupMember' => nil, # Bool
      'DemobilizeUsers' => nil, # Bool
      'EnableFDE' => nil, # Bool
      'EnableFDERecoveryKey' => nil, # Bool
      'EULAPath' => nil, # String
      'EULASubTitle' => nil, # String
      'EULAText' => nil, # String
      'EULATitle' => nil, # String
      'KeychainAddNoMAD' => nil, # Bool
      'KeychainCreate' => nil, # Bool
      'KeychainReset' => nil, # Bool
      'LDAPOverSSL' => nil, # Bool
      'LoginLogo' => nil, # String
      'LoginLogoData' => nil, # Data
      'LoginScreen' => nil, # Bool
      'UsernameFieldPlaceholder' => nil, # String
      'UserProfileImage' => nil, # String
    },
  },
  'actions' => {
    'prefs' => {
      'Version' => nil, # Int
      'MenuIcon' => nil, # Bool
      'MenuText' => nil, # Bool
      'Actions' => nil, # Dictionary
    },
  },
}
