cpe_nomad Cookbook
==================
NoMAD is an app to manage kerberos authentication tickets without
having a cached AD account.

Requirements
------------
macOS

Attributes
----------
* node['cpe_nomad']
* node['cpe_nomad']['install']
* node['cpe_nomad']['uninstall']
* node['cpe_nomad']['enable']
* node['cpe_nomad']['profile']
* node['cpe_nomad']['pkg']
* node['cpe_nomad']['pkg']['name']
* node['cpe_nomad']['pkg']['checksum']
* node['cpe_nomad']['pkg']['receipt']
* node['cpe_nomad']['pkg']['version']
* node['cpe_nomad']['pkg']['pkg_name']
* node['cpe_nomad']['pkg']['pkg_url']
* node['cpe_nomad']['launchagent']
* node['cpe_nomad']['launchagent']['program_arguments']
* node['cpe_nomad']['launchagent']['run_at_load']
* node['cpe_nomad']['launchagent']['limit_load_to_session_type']
* node['cpe_nomad']['launchagent']['type']
* node['cpe_nomad']['prefs']
* node['cpe_nomad']['prefs']['ADDomain']
* node['cpe_nomad']['prefs']['AutoConfigure']
* node['cpe_nomad']['prefs']['prefs']
* node['cpe_nomad']['prefs']['AutoRenewCert']
* node['cpe_nomad']['prefs']['CaribouTime']
* node['cpe_nomad']['prefs']['ChangePasswordCommand']
* node['cpe_nomad']['prefs']['ChangePasswordOptions']
* node['cpe_nomad']['prefs']['ChangePasswordType']
* node['cpe_nomad']['prefs']['CleanCerts']
* node['cpe_nomad']['prefs']['ConfigureChrome']
* node['cpe_nomad']['prefs']['ConfigureChromeDomain']
* node['cpe_nomad']['prefs']['CustomLDAPAttributes']
* node['cpe_nomad']['prefs']['DontMatchKerbPrefs']
* node['cpe_nomad']['prefs']['DontShowWelcome']
* node['cpe_nomad']['prefs']['DontShowWelcomeDefaultOn']
* node['cpe_nomad']['prefs']['ExpeditedLookups']
* node['cpe_nomad']['prefs']['ExportableKey']
* node['cpe_nomad']['prefs']['GetCertificateAutomatically']
* node['cpe_nomad']['prefs']['GetHelpOptions']
* node['cpe_nomad']['prefs']['GetHelpType']
* node['cpe_nomad']['prefs']['HicFix']
* node['cpe_nomad']['prefs']['HideExpiration']
* node['cpe_nomad']['prefs']['HideAbout']
* node['cpe_nomad']['prefs']['HideExpirationMessage']
* node['cpe_nomad']['prefs']['HideGetSoftware']
* node['cpe_nomad']['prefs']['HideHelp']
* node['cpe_nomad']['prefs']['HideLockScreen']
* node['cpe_nomad']['prefs']['HidePrefs']
* node['cpe_nomad']['prefs']['HideRenew']
* node['cpe_nomad']['prefs']['HideSignOut']
* node['cpe_nomad']['prefs']['HideQuit']
* node['cpe_nomad']['prefs']['HomeAppendDomain']
* node['cpe_nomad']['prefs']['IconOff']
* node['cpe_nomad']['prefs']['IconOffDark']
* node['cpe_nomad']['prefs']['IconOn']
* node['cpe_nomad']['prefs']['IconOnDark']
* node['cpe_nomad']['prefs']['InternalSite']
* node['cpe_nomad']['prefs']['InternalSiteIP']
* node['cpe_nomad']['prefs']['KerberosRealm']
* node['cpe_nomad']['prefs']['KeychainItems']
* node['cpe_nomad']['prefs']['LDAPAnonymous']]
* node['cpe_nomad']['prefs']['LDAPServerList']
* node['cpe_nomad']['prefs']['LDAPOnly']
* node['cpe_nomad']['prefs']['LDAPOverSSL']
* node['cpe_nomad']['prefs']['LDAPType']
* node['cpe_nomad']['prefs']['LightsOutIKnowWhatImDoing']
* node['cpe_nomad']['prefs']['LocalPasswordSync']
* node['cpe_nomad']['prefs']['LocalPasswordSyncDontSyncLocalUsers']
* node['cpe_nomad']['prefs']['LocalPasswordSyncDontSyncNetworkUsers']
* node['cpe_nomad']['prefs']['LocalPasswordSyncOnMatchOnly']
* node['cpe_nomad']['prefs']['LoginItem']
* node['cpe_nomad']['prefs']['MenuAbout']
* node['cpe_nomad']['prefs']['MenuChangePassword']
* node['cpe_nomad']['prefs']['MenuGetCertificate']
* node['cpe_nomad']['prefs']['MenuHomeDirectory']
* node['cpe_nomad']['prefs']['MenuGetHelp']
* node['cpe_nomad']['prefs']['MenuGetSoftware']
* node['cpe_nomad']['prefs']['MenuPasswordExpires']
* node['cpe_nomad']['prefs']['MenuRenewTickets']
* node['cpe_nomad']['prefs']['MenuUserName']
* node['cpe_nomad']['prefs']['MenuWelcome']
* node['cpe_nomad']['prefs']['MessageLocalSync']
* node['cpe_nomad']['prefs']['MessageNotConnected']
* node['cpe_nomad']['prefs']['MessagePasswordChangePolicy']
* node['cpe_nomad']['prefs']['MessageUPCAlert']
* node['cpe_nomad']['prefs']['MountSharesWithFinder']
* node['cpe_nomad']['prefs']['PasswordExpireAlertTime']
* node['cpe_nomad']['prefs']['PasswordExpireCustomAlert']
* node['cpe_nomad']['prefs']['PasswordExpireCustomWarnTime']
* node['cpe_nomad']['prefs']['PasswordExpireCustomAlertTime']
* node['cpe_nomad']['prefs']['PasswordPolicy']
* node['cpe_nomad']['prefs']['PersistExpiration']
* node['cpe_nomad']['prefs']['RecursiveGroupLookup']
* node['cpe_nomad']['prefs']['RenewTickets']
* node['cpe_nomad']['prefs']['SecondsToRenew']
* node['cpe_nomad']['prefs']['SelfServicePath']
* node['cpe_nomad']['prefs']['ShowHome']
* node['cpe_nomad']['prefs']['SignInCommand']
* node['cpe_nomad']['prefs']['SignInWindowAlert']
* node['cpe_nomad']['prefs']['SignInWindowAlertTime']
* node['cpe_nomad']['prefs']['SignInWindowOnLaunch']
* node['cpe_nomad']['prefs']['SignInWindowOnLaunchExclusions']
* node['cpe_nomad']['prefs']['SignOutCommand']
* node['cpe_nomad']['prefs']['StateChangeAction']
* node['cpe_nomad']['prefs']['Template']
* node['cpe_nomad']['prefs']['TitleSignIn']
* node['cpe_nomad']['prefs']['UPCAlert']
* node['cpe_nomad']['prefs']['UPCAlertAction']
* node['cpe_nomad']['prefs']['UPCAlertAction']
* node['cpe_nomad']['prefs']['UseKeychainPrompt']
* node['cpe_nomad']['prefs']['UserSwitch']
* node['cpe_nomad']['prefs']['Verbose']
* node['cpe_nomad']['prefs']['WifiNetworks']
* node['cpe_nomad']['prefs']['X509CA']
* node['cpe_nomad']['login']['install']['ADDomain']
* node['cpe_nomad']['login']['enable']['ADDomain']
* node['cpe_nomad']['login']['pkg']
* node['cpe_nomad']['login']['pkg']['name']
* node['cpe_nomad']['login']['pkg']['checksum']
* node['cpe_nomad']['login']['pkg']['receipt']
* node['cpe_nomad']['login']['pkg']['version']
* node['cpe_nomad']['login']['pkg']['pkg_name']
* node['cpe_nomad']['login']['pkg']['pkg_url']
* node['cpe_nomad']['login']['prefs']['ADDomain']
* node['cpe_nomad']['login']['prefs']['AdditionalADDomains']
* node['cpe_nomad']['login']['prefs']['BackgroundImage']
* node['cpe_nomad']['login']['prefs']['BackgroundImageAlpha']
* node['cpe_nomad']['login']['prefs']['BackgroundImageAlpha']
* node['cpe_nomad']['login']['prefs']['createAdminUser']
* node['cpe_nomad']['login']['prefs']['CreateAdminIfGroupMember']
* node['cpe_nomad']['login']['prefs']['DemobilizeUsers']
* node['cpe_nomad']['login']['prefs']['EnableFDE']
* node['cpe_nomad']['login']['prefs']['EnableFDERecoveryKey']
* node['cpe_nomad']['login']['prefs']['EULAPath']
* node['cpe_nomad']['login']['prefs']['EULASubTitle']
* node['cpe_nomad']['login']['prefs']['EULAText']
* node['cpe_nomad']['login']['prefs']['EULATitle']
* node['cpe_nomad']['login']['prefs']['KeychainAddNoMAD']
* node['cpe_nomad']['login']['prefs']['KeychainCreate']
* node['cpe_nomad']['login']['prefs']['KeychainReset']
* node['cpe_nomad']['login']['prefs']['LDAPOverSSL']
* node['cpe_nomad']['login']['prefs']['LoginLogo']
* node['cpe_nomad']['login']['prefs']['LoginLogoData']
* node['cpe_nomad']['login']['prefs']['LoginScreen']
* node['cpe_nomad']['login']['prefs']['UsernameFieldPlaceholder']
* node['cpe_nomad']['login']['prefs']['UserProfileImage']
* node['cpe_nomad']['actions']['prefs']['Version']
* node['cpe_nomad']['actions']['prefs']['MenuIcon']
* node['cpe_nomad']['actions']['prefs']['MenuText']
* node['cpe_nomad']['actions']['prefs']['Actions']

Usage
-----
`node['cpe_nomad']['install']` declares whether to install NoMAD.app.
The default setting is `false`, so that NoMAD.app is not installed by default.

`node['cpe_nomad']['launchagent']` will configure and manage a LaunchAgent
to load NoMAD.app.

`node['cpe_nomad']['prefs']` will manage the `com.trusourcelabs.NoMAD`
preference domain. See NoMAD's [site for documentation](https://nomad.menu/help-center/preferences-and-what-they-do/)
 on preference keys and values.

`node['cpe_nomad']['login']['prefs']` will manage the `menu.nomad.login.ad`
preference domain. See NoMADLoginAD's [site for documentation](https://gitlab.com/orchardandgrove-oss/NoMADLogin-AD/wikis/Configuration/preferences)
on preference keys and values.

`node['cpe_nomad']['actions']['prefs']` will manage the `menu.nomad.actions'`
preference domain. See NoMAD's [site for documentation](https://gitlab.com/Mactroll/NoMAD/blob/Experimental/NoMAD/ACTIONS%20README.md)
on preference keys and values.

The profile's organization key defaults to `Facebook` unless
`node['organization']` is configured in your company's custom init recipe.
The profile will also use whichever prefix is set in
node['cpe_profiles']['prefix'], which defaults to `com.facebook.chef`

The profiles deliver payloads of all keys that are non-nil values.
The provided defaults are nil, so that no profiles are installed by default.

You can add any arbitrary keys to have them added to your profile.
As long as the values are not nil and create valid profiles,
this cookbook will install and manage them.

```
# Add ADDomain to NoMAD
node.default['cpe_nomad']['prefs']['ADDomain'] = 'ad.example.com'

## Add custom NoMAD Menu Actions
[
  {
    'Name' => 'Example URL',
    'Action' => [
      {
        'Command' => 'url',
        'CommandOptions' => 'https://example.com',
      },
    ],
  },
].each { |i| node.default['cpe_nomad']['actions']['prefs']['Actions'] << i }
```
