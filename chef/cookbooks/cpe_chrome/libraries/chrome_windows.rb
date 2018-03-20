#
# Cookbook Name:: cpe_browsers
# Library:: chrome_windows
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

# This addition to the FB namespace is specific to managing Chrome enterprise
# settings on Windows.
module FB
  # The Chef registry providers require the corresponding registry key types
  # (i.e. REG_DWORD, REG_STRING) to write the settings into the registry which
  # are explicitly laid out in this module.
  module ChromeManagement
    # This is the root registry key that will be used to prefix all of the
    # subsequent registry keys listed in this file.
    # You can store the keys either in HKEY_LOCAL_MACHINE or HKEY_CURRENT_USER.
    # HKEY_LOCAL_MACHINE settings take precedence over user HKEY_CURRENT_USER
    # settings.
    CHROME_REG_ROOT = 'Software\Policies\Google\Chrome'

    # These are keys that will take some of the more complex data types used in
    # the Windows registry. Values are grabbed from:
    # https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip
    # in the chrome.reg file
    COMPLEX_REG_KEYS = {
      'Chrome' => {
        'AdditionalLaunchParameters' => :string,
        'AllowCrossOriginAuthPrompt' => :dword,
        'AllowFileSelectionDialogs' => :dword,
        'AllowOutdatedPlugins' => :dword,
        'AlternateErrorPagesEnabled' => :dword,
        'AlwaysAuthorizePlugins' => :dword,
        'ApplicationLocaleValue' => :string,
        'AudioCaptureAllowed' => :dword,
        'AuthNegotiateDelegateWhitelist' => :string,
        'AuthSchemes' => :string,
        'AuthServerWhitelist' => :string,
        'AutoFillEnabled' => :dword,
        'BackgroundModeEnabled' => :dword,
        'BlockThirdPartyCookies' => :dword,
        'BookmarkBarEnabled' => :dword,
        'BrowserAddPersonEnabled' => :dword,
        'BrowserGuestModeEnabled' => :dword,
        'BuiltInDnsClientEnabled' => :dword,
        'ChromeFrameRendererSettings' => :dword,
        'CloudPrintProxyEnabled' => :dword,
        'CloudPrintSubmitEnabled' => :dword,
        'DefaultBrowserSettingEnabled' => :dword,
        'DefaultCookiesSetting' => :dword,
        'DefaultGeolocationSetting' => :dword,
        'DefaultImagesSetting' => :dword,
        'DefaultJavaScriptSetting' => :dword,
        'DefaultNotificationsSetting' => :dword,
        'DefaultPluginsSetting' => :dword,
        'DefaultPopupsSetting' => :dword,
        'DefaultSearchProviderEnabled' => :dword,
        'DefaultSearchProviderIconURL' => :string,
        'DefaultSearchProviderImageURL' => :string,
        'DefaultSearchProviderImageURLPostParams' => :string,
        'DefaultSearchProviderInstantURL' => :string,
        'DefaultSearchProviderInstantURLPostParams' => :string,
        'DefaultSearchProviderKeyword' => :string,
        'DefaultSearchProviderName' => :string,
        'DefaultSearchProviderNewTabURL' => :string,
        'DefaultSearchProviderSearchTermsReplacementKey' => :string,
        'DefaultSearchProviderSearchURL' => :string,
        'DefaultSearchProviderSearchURLPostParams' => :string,
        'DefaultSearchProviderSuggestURL' => :string,
        'DefaultSearchProviderSuggestURLPostParams' => :string,
        'DeveloperToolsDisabled' => :dword,
        'Disable3DAPIs' => :dword,
        'DisableAuthNegotiateCnameLookup' => :dword,
        'DisablePluginFinder' => :dword,
        'DisableSSLRecordSplitting' => :dword,
        'DisableSafeBrowsingProceedAnyway' => :dword,
        'DisableScreenshots' => :dword,
        'DisableSpdy' => :dword,
        'DiskCacheDir' => :string,
        'DiskCacheSize' => :dword,
        'DnsPrefetchingEnabled' => :dword,
        'DownloadDirectory' => :string,
        'EditBookmarksEnabled' => :dword,
        'EnableAuthNegotiatePort' => :dword,
        'EnableOnlineRevocationChecks' => :dword,
        'ForceEphemeralProfiles' => :dword,
        'ForceGoogleSafeSearch' => :dword,
        'ForceYouTubeSafetyMode' => :dword,
        'FullscreenAllowed' => :dword,
        'GCFUserDataDir' => :string,
        'HideWebStoreIcon' => :dword,
        'HomepageIsNewTabPage' => :dword,
        'HomepageLocation' => :string,
        'ImportAutofillFormData' => :dword,
        'ImportBookmarks' => :dword,
        'ImportHistory' => :dword,
        'ImportHomepage' => :dword,
        'ImportSavedPasswords' => :dword,
        'ImportSearchEngine' => :dword,
        'IncognitoModeAvailability' => :dword,
        'ManagedBookmarks' => :multi_string,
        'MaxConnectionsPerProxy' => :dword,
        'MaxInvalidationFetchDelay' => :dword,
        'MediaCacheSize' => :dword,
        'MetricsReportingEnabled' => :dword,
        'NativeMessagingUserLevelHosts' => :dword,
        'NetworkPredictionOptions' => :dword,
        'PasswordManagerAllowShowPasswords' => :dword,
        'PasswordManagerEnabled' => :dword,
        'PrintingEnabled' => :dword,
        'ProxyBypassList' => :string,
        'ProxyMode' => :string,
        'ProxyPacUrl' => :string,
        'ProxyServer' => :string,
        'QuicAllowed' => :dword,
        'RemoteAccessHostAllowClientPairing' => :dword,
        'RemoteAccessHostAllowGnubbyAuth' => :dword,
        'RemoteAccessHostAllowRelayedConnection' => :dword,
        'RemoteAccessHostDebugOverridePolicies' => :string,
        'RemoteAccessHostDomain' => :string,
        'RemoteAccessHostFirewallTraversal' => :dword,
        'RemoteAccessHostRequireCurtain' => :dword,
        'RemoteAccessHostTalkGadgetPrefix' => :string,
        'RemoteAccessHostTokenUrl' => :string,
        'RemoteAccessHostTokenValidationCertificateIssuer' => :string,
        'RemoteAccessHostTokenValidationUrl' => :string,
        'RemoteAccessHostUdpPortRange' => :string,
        'RequireOnlineRevocationChecksForLocalAnchors' => :dword,
        'RestoreOnStartup' => :dword,
        'RestrictSigninToPattern' => :string,
        'SSLVersionFallbackMin' => :string,
        'SSLVersionMin' => :string,
        'SafeBrowsingEnabled' => :dword,
        'SavingBrowserHistoryDisabled' => :dword,
        'SearchSuggestEnabled' => :dword,
        'ShowAppsShortcutInBookmarkBar' => :dword,
        'ShowHomeButton' => :dword,
        'SitePerProcess' => :dword,
        'SkipMetadataCheck' => :dword,
        'SpellCheckServiceEnabled' => :dword,
        'SupervisedUserCreationEnabled' => :dword,
        'SuppressChromeFrameTurndownPrompt' => :dword,
        'SyncDisabled' => :dword,
        'TranslateEnabled' => :dword,
        'UserDataDir' => :string,
        'VideoCaptureAllowed' => :dword,
        'WPADQuickCheckEnabled' => :dword,
      },
      'Recommended' => {
        'AlternateErrorPagesEnabled' => :dword,
        'ApplicationLocaleValue' => :string,
        'AutoFillEnabled' => :dword,
        'BackgroundModeEnabled' => :dword,
        'BlockThirdPartyCookies' => :dword,
        'BookmarkBarEnabled' => :dword,
        'DnsPrefetchingEnabled' => :dword,
        'DownloadDirectory' => :string,
        'HomepageIsNewTabPage' => :dword,
        'HomepageLocation' => :string,
        'ImportAutofillFormData' => :dword,
        'ImportBookmarks' => :dword,
        'ImportHistory' => :dword,
        'ImportSavedPasswords' => :dword,
        'ImportSearchEngine' => :dword,
        'MetricsReportingEnabled' => :dword,
        'NetworkPredictionOptions' => :dword,
        'PasswordManagerEnabled' => :dword,
        'RegisteredProtocolHandlers' => :multi_string,
        'RestoreOnStartup' => :dword,
        'SafeBrowsingEnabled' => :dword,
        'SearchSuggestEnabled' => :dword,
        'ShowHomeButton' => :dword,
        'SpellCheckServiceEnabled' => :dword,
        'TranslateEnabled' => :dword,
      },
    }

    # These are keys that will accept string values. For each registry key under
    # the registry hive they are labeled with a number and then the
    # corresponding string value. For example,
    # [HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLWhitelist]
    # "1"="example.com"
    # "2"="https://ssl.server.com"
    # "3"="hosting.com/bad_path"
    # "4"="http://server:8080/path"
    # "5"=".exact.hostname.com"
    ENUM_REG_KEYS = {
      'AudioCaptureAllowedUrls' => :string,
      'AutoSelectCertificateForUrls' => :string,
      'ChromeFrameContentTypes' => :string,
      'CookiesAllowedForUrls' => :string,
      'CookiesBlockedForUrls' => :string,
      'CookiesSessionOnlyForUrls' => :string,
      'DefaultSearchProviderAlternateURLs' => :string,
      'DefaultSearchProviderEncodings' => :string,
      'DisabledPlugins' => :string,
      'DisabledPluginsExceptions' => :string,
      'EnableDeprecatedWebPlatformFeatures' => :string,
      'EnabledPlugins' => :string,
      'ExtensionAllowedTypes' => :string,
      'ExtensionInstallBlacklist' => :string,
      'ExtensionInstallForcelist' => :string,
      'ExtensionInstallSources' => :string,
      'ExtensionInstallWhitelist' => :string,
      'ImagesAllowedForUrls' => :string,
      'ImagesBlockedForUrls' => :string,
      'JavaScriptAllowedForUrls' => :string,
      'JavaScriptBlockedForUrls' => :string,
      'NativeMessagingBlacklist' => :string,
      'NativeMessagingWhitelist' => :string,
      'NotificationsAllowedForUrls' => :string,
      'NotificationsBlockedForUrls' => :string,
      'PluginsAllowedForUrls' => :string,
      'PluginsBlockedForUrls' => :string,
      'PopupsAllowedForUrls' => :string,
      'PopupsBlockedForUrls' => :string,
      'Recommended\RestoreOnStartupURLs' => :string,
      'RenderInChromeFrameList' => :string,
      'RenderInHostList' => :string,
      'RestoreOnStartupURLs' => :string,
      'URLBlacklist' => :string,
      'URLWhitelist' => :string,
      'VideoCaptureAllowedUrls' => :string,
    }
  end unless defined?(FB::ChromeManagement)
end
