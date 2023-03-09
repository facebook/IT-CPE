#
# Cookbook Name:: cpe_chrome
# Library:: gen_windows_chrome_known_settings
#
# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# rubocop:disable Metrics/LineLength
# @generated
require_relative 'windows_chrome_settingv2'

module CPE
  module ChromeManagement
    module KnownSettings
      GENERATED = {
              "AbusiveExperienceInterventionEnforce" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AbusiveExperienceInterventionEnforce', 
:dword, 
false,),
              "AccessCodeCastDeviceDuration" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AccessCodeCastDeviceDuration', 
:dword, 
false,),
              "AccessCodeCastEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AccessCodeCastEnabled', 
:dword, 
false,),
              "AccessibilityImageLabelsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AccessibilityImageLabelsEnabled', 
:dword, 
false,),
              "AdditionalDnsQueryTypesEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AdditionalDnsQueryTypesEnabled', 
:dword, 
false,),
              "AdsSettingForIntrusiveAdsSites" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AdsSettingForIntrusiveAdsSites', 
:dword, 
false,),
              "AdvancedProtectionAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AdvancedProtectionAllowed', 
:dword, 
false,),
              "AllowCrossOriginAuthPrompt" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AllowCrossOriginAuthPrompt', 
:dword, 
false,),
              "AllowDeletingBrowserHistory" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AllowDeletingBrowserHistory', 
:dword, 
false,),
              "AllowDinosaurEasterEgg" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AllowDinosaurEasterEgg', 
:dword, 
false,),
              "AllowFileSelectionDialogs" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AllowFileSelectionDialogs', 
:dword, 
false,),
              "AllowedDomainsForApps" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AllowedDomainsForApps', 
:string, 
false,),
              "AlternateErrorPagesEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'AlternateErrorPagesEnabled', 
:dword, 
false,),
              "AlternativeBrowserPath" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AlternativeBrowserPath', 
:string, 
false,),
              "AlwaysOpenPdfExternally" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'AlwaysOpenPdfExternally', 
:dword, 
false,),
              "AmbientAuthenticationInPrivateModesEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AmbientAuthenticationInPrivateModesEnabled', 
:dword, 
false,),
              "ApplicationLocaleValue" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ApplicationLocaleValue', 
:string, 
false,),
              "AssistantWebEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AssistantWebEnabled', 
:dword, 
false,),
              "AudioCaptureAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AudioCaptureAllowed', 
:dword, 
false,),
              "AudioProcessHighPriorityEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AudioProcessHighPriorityEnabled', 
:dword, 
false,),
              "AudioSandboxEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AudioSandboxEnabled', 
:dword, 
false,),
              "AuthNegotiateDelegateAllowlist" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AuthNegotiateDelegateAllowlist', 
:string, 
false,),
              "AuthSchemes" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AuthSchemes', 
:string, 
false,),
              "AuthServerAllowlist" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AuthServerAllowlist', 
:string, 
false,),
              "AutoLaunchProtocolsFromOrigins" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AutoLaunchProtocolsFromOrigins', 
:string, 
false,),
              "AutofillAddressEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'AutofillAddressEnabled', 
:dword, 
false,),
              "AutofillCreditCardEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'AutofillCreditCardEnabled', 
:dword, 
false,),
              "AutoplayAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'AutoplayAllowed', 
:dword, 
false,),
              "BackgroundModeEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'BackgroundModeEnabled', 
:dword, 
false,),
              "BasicAuthOverHttpEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BasicAuthOverHttpEnabled', 
:dword, 
false,),
              "BatterySaverModeAvailability" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'BatterySaverModeAvailability', 
:dword, 
false,),
              "BlockExternalExtensions" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BlockExternalExtensions', 
:dword, 
false,),
              "BlockThirdPartyCookies" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'BlockThirdPartyCookies', 
:dword, 
false,),
              "BookmarkBarEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'BookmarkBarEnabled', 
:dword, 
false,),
              "BrowserAddPersonEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserAddPersonEnabled', 
:dword, 
false,),
              "BrowserGuestModeEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserGuestModeEnabled', 
:dword, 
false,),
              "BrowserGuestModeEnforced" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserGuestModeEnforced', 
:dword, 
false,),
              "BrowserLabsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserLabsEnabled', 
:dword, 
false,),
              "BrowserLegacyExtensionPointsBlocked" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserLegacyExtensionPointsBlocked', 
:dword, 
false,),
              "BrowserNetworkTimeQueriesEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserNetworkTimeQueriesEnabled', 
:dword, 
false,),
              "BrowserSignin" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSignin', 
:dword, 
false,),
              "BrowserSwitcherChromePath" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherChromePath', 
:string, 
false,),
              "BrowserSwitcherDelay" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherDelay', 
:dword, 
false,),
              "BrowserSwitcherEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherEnabled', 
:dword, 
false,),
              "BrowserSwitcherExternalGreylistUrl" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherExternalGreylistUrl', 
:string, 
false,),
              "BrowserSwitcherExternalSitelistUrl" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherExternalSitelistUrl', 
:string, 
false,),
              "BrowserSwitcherKeepLastChromeTab" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherKeepLastChromeTab', 
:dword, 
false,),
              "BrowserSwitcherParsingMode" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherParsingMode', 
:dword, 
false,),
              "BrowserSwitcherUseIeSitelist" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserSwitcherUseIeSitelist', 
:dword, 
false,),
              "BrowserThemeColor" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowserThemeColor', 
:string, 
false,),
              "BrowsingDataLifetime" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BrowsingDataLifetime', 
:string, 
false,),
              "BuiltInDnsClientEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'BuiltInDnsClientEnabled', 
:dword, 
false,),
              "CECPQ2Enabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CECPQ2Enabled', 
:dword, 
false,),
              "CORSNonWildcardRequestHeadersSupport" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CORSNonWildcardRequestHeadersSupport', 
:dword, 
false,),
              "ChromeAppsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ChromeAppsEnabled', 
:dword, 
false,),
              "ChromeCleanupEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ChromeCleanupEnabled', 
:dword, 
false,),
              "ChromeCleanupReportingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ChromeCleanupReportingEnabled', 
:dword, 
false,),
              "ChromeRootStoreEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ChromeRootStoreEnabled', 
:dword, 
false,),
              "ChromeVariations" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ChromeVariations', 
:dword, 
false,),
              "ClickToCallEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ClickToCallEnabled', 
:dword, 
false,),
              "CloudManagementEnrollmentMandatory" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CloudManagementEnrollmentMandatory', 
:dword, 
false,),
              "CloudManagementEnrollmentToken" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CloudManagementEnrollmentToken', 
:string, 
false,),
              "CloudPolicyOverridesPlatformPolicy" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CloudPolicyOverridesPlatformPolicy', 
:dword, 
false,),
              "CloudPrintProxyEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CloudPrintProxyEnabled', 
:dword, 
false,),
              "CloudUserPolicyMerge" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CloudUserPolicyMerge', 
:dword, 
false,),
              "CloudUserPolicyOverridesCloudMachinePolicy" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CloudUserPolicyOverridesCloudMachinePolicy', 
:dword, 
false,),
              "CommandLineFlagSecurityWarningsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CommandLineFlagSecurityWarningsEnabled', 
:dword, 
false,),
              "ComponentUpdatesEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ComponentUpdatesEnabled', 
:dword, 
false,),
              "DNSInterceptionChecksEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DNSInterceptionChecksEnabled', 
:dword, 
false,),
              "DefaultBrowserSettingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultBrowserSettingEnabled', 
:dword, 
false,),
              "DefaultClipboardSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultClipboardSetting', 
:dword, 
false,),
              "DefaultCookiesSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultCookiesSetting', 
:dword, 
false,),
              "DefaultFileSystemReadGuardSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultFileSystemReadGuardSetting', 
:dword, 
false,),
              "DefaultFileSystemWriteGuardSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultFileSystemWriteGuardSetting', 
:dword, 
false,),
              "DefaultGeolocationSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultGeolocationSetting', 
:dword, 
false,),
              "DefaultImagesSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultImagesSetting', 
:dword, 
false,),
              "DefaultInsecureContentSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultInsecureContentSetting', 
:dword, 
false,),
              "DefaultJavaScriptJitSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultJavaScriptJitSetting', 
:dword, 
false,),
              "DefaultJavaScriptSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultJavaScriptSetting', 
:dword, 
false,),
              "DefaultLocalFontsSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultLocalFontsSetting', 
:dword, 
false,),
              "DefaultNotificationsSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultNotificationsSetting', 
:dword, 
false,),
              "DefaultPopupsSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultPopupsSetting', 
:dword, 
false,),
              "DefaultPrinterSelection" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultPrinterSelection', 
:string, 
false,),
              "DefaultSearchProviderContextMenuAccessAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderContextMenuAccessAllowed', 
:dword, 
false,),
              "DefaultSearchProviderEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderEnabled', 
:dword, 
false,),
              "DefaultSearchProviderIconURL" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderIconURL', 
:string, 
false,),
              "DefaultSearchProviderImageURL" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderImageURL', 
:string, 
false,),
              "DefaultSearchProviderImageURLPostParams" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderImageURLPostParams', 
:string, 
false,),
              "DefaultSearchProviderKeyword" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderKeyword', 
:string, 
false,),
              "DefaultSearchProviderName" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderName', 
:string, 
false,),
              "DefaultSearchProviderNewTabURL" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderNewTabURL', 
:string, 
false,),
              "DefaultSearchProviderSearchURL" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderSearchURL', 
:string, 
false,),
              "DefaultSearchProviderSearchURLPostParams" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderSearchURLPostParams', 
:string, 
false,),
              "DefaultSearchProviderSuggestURL" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderSuggestURL', 
:string, 
false,),
              "DefaultSearchProviderSuggestURLPostParams" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultSearchProviderSuggestURLPostParams', 
:string, 
false,),
              "DefaultSensorsSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultSensorsSetting', 
:dword, 
false,),
              "DefaultSerialGuardSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultSerialGuardSetting', 
:dword, 
false,),
              "DefaultWebBluetoothGuardSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultWebBluetoothGuardSetting', 
:dword, 
false,),
              "DefaultWebHidGuardSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultWebHidGuardSetting', 
:dword, 
false,),
              "DefaultWebUsbGuardSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultWebUsbGuardSetting', 
:dword, 
false,),
              "DefaultWindowPlacementSetting" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DefaultWindowPlacementSetting', 
:dword, 
false,),
              "DesktopSharingHubEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DesktopSharingHubEnabled', 
:dword, 
false,),
              "DeveloperToolsAvailability" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DeveloperToolsAvailability', 
:dword, 
false,),
              "Disable3DAPIs" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'Disable3DAPIs', 
:dword, 
false,),
              "DisableAuthNegotiateCnameLookup" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DisableAuthNegotiateCnameLookup', 
:dword, 
false,),
              "DisablePrintPreview" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DisablePrintPreview', 
:dword, 
false,),
              "DisableSafeBrowsingProceedAnyway" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DisableSafeBrowsingProceedAnyway', 
:dword, 
false,),
              "DisableScreenshots" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DisableScreenshots', 
:dword, 
false,),
              "DiskCacheDir" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DiskCacheDir', 
:string, 
false,),
              "DiskCacheSize" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DiskCacheSize', 
:dword, 
false,),
              "DnsOverHttpsMode" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DnsOverHttpsMode', 
:string, 
false,),
              "DnsOverHttpsTemplates" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DnsOverHttpsTemplates', 
:string, 
false,),
              "DownloadBubbleEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'DownloadBubbleEnabled', 
:dword, 
false,),
              "DownloadDirectory" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DownloadDirectory', 
:string, 
false,),
              "DownloadRestrictions" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DownloadRestrictions', 
:dword, 
false,),
              "EditBookmarksEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'EditBookmarksEnabled', 
:dword, 
false,),
              "EnableAuthNegotiatePort" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'EnableAuthNegotiatePort', 
:dword, 
false,),
              "EnableMediaRouter" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'EnableMediaRouter', 
:dword, 
false,),
              "EnableOnlineRevocationChecks" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'EnableOnlineRevocationChecks', 
:dword, 
false,),
              "EncryptedClientHelloEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'EncryptedClientHelloEnabled', 
:dword, 
false,),
              "EnterpriseHardwarePlatformAPIEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'EnterpriseHardwarePlatformAPIEnabled', 
:dword, 
false,),
              "EnterpriseProfileCreationKeepBrowsingData" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'EnterpriseProfileCreationKeepBrowsingData', 
:dword, 
false,),
              "EventPathEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'EventPathEnabled', 
:dword, 
false,),
              "ExemptDomainFileTypePairsFromFileTypeDownloadWarnings" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ExemptDomainFileTypePairsFromFileTypeDownloadWarnings', 
:string, 
false,),
              "ExtensionSettings" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ExtensionSettings', 
:string, 
false,),
              "ExternalProtocolDialogShowAlwaysOpenCheckbox" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ExternalProtocolDialogShowAlwaysOpenCheckbox', 
:dword, 
false,),
              "FetchKeepaliveDurationSecondsOnShutdown" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'FetchKeepaliveDurationSecondsOnShutdown', 
:dword, 
false,),
              "FileSystemSyncAccessHandleAsyncInterfaceEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'FileSystemSyncAccessHandleAsyncInterfaceEnabled', 
:dword, 
false,),
              "ForceEphemeralProfiles" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ForceEphemeralProfiles', 
:dword, 
false,),
              "ForceGoogleSafeSearch" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ForceGoogleSafeSearch', 
:dword, 
false,),
              "ForceMajorVersionToMinorPositionInUserAgent" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ForceMajorVersionToMinorPositionInUserAgent', 
:dword, 
false,),
              "ForceYouTubeRestrict" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ForceYouTubeRestrict', 
:dword, 
false,),
              "FullscreenAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'FullscreenAllowed', 
:dword, 
false,),
              "GloballyScopeHTTPAuthCacheEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'GloballyScopeHTTPAuthCacheEnabled', 
:dword, 
false,),
              "HardwareAccelerationModeEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'HardwareAccelerationModeEnabled', 
:dword, 
false,),
              "HeadlessMode" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'HeadlessMode', 
:dword, 
false,),
              "HideWebStoreIcon" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'HideWebStoreIcon', 
:dword, 
false,),
              "HighEfficiencyModeEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'HighEfficiencyModeEnabled', 
:dword, 
false,),
              "HistoryClustersVisible" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'HistoryClustersVisible', 
:dword, 
false,),
              "HomepageIsNewTabPage" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'HomepageIsNewTabPage', 
:dword, 
false,),
              "HomepageLocation" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'HomepageLocation', 
:string, 
false,),
              "HttpsOnlyMode" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'HttpsOnlyMode', 
:string, 
false,),
              "ImportAutofillFormData" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ImportAutofillFormData', 
:dword, 
false,),
              "ImportBookmarks" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ImportBookmarks', 
:dword, 
false,),
              "ImportHistory" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ImportHistory', 
:dword, 
false,),
              "ImportHomepage" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ImportHomepage', 
:dword, 
false,),
              "ImportSavedPasswords" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ImportSavedPasswords', 
:dword, 
false,),
              "ImportSearchEngine" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ImportSearchEngine', 
:dword, 
false,),
              "IncognitoModeAvailability" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'IncognitoModeAvailability', 
:dword, 
false,),
              "InsecureFormsWarningsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'InsecureFormsWarningsEnabled', 
:dword, 
false,),
              "InsecurePrivateNetworkRequestsAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'InsecurePrivateNetworkRequestsAllowed', 
:dword, 
false,),
              "IntensiveWakeUpThrottlingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'IntensiveWakeUpThrottlingEnabled', 
:dword, 
false,),
              "IntranetRedirectBehavior" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'IntranetRedirectBehavior', 
:dword, 
false,),
              "IsolateOrigins" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'IsolateOrigins', 
:string, 
false,),
              "LensRegionSearchEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'LensRegionSearchEnabled', 
:dword, 
false,),
              "ManagedAccountsSigninRestriction" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ManagedAccountsSigninRestriction', 
:string, 
false,),
              "ManagedBookmarks" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ManagedBookmarks', 
:string, 
false,),
              "ManagedConfigurationPerOrigin" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ManagedConfigurationPerOrigin', 
:string, 
false,),
              "MaxConnectionsPerProxy" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'MaxConnectionsPerProxy', 
:dword, 
false,),
              "MaxInvalidationFetchDelay" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'MaxInvalidationFetchDelay', 
:dword, 
false,),
              "MediaRecommendationsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'MediaRecommendationsEnabled', 
:dword, 
false,),
              "MediaRouterCastAllowAllIPs" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'MediaRouterCastAllowAllIPs', 
:dword, 
false,),
              "MetricsReportingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'MetricsReportingEnabled', 
:dword, 
false,),
              "NTPCardsVisible" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'NTPCardsVisible', 
:dword, 
false,),
              "NTPCustomBackgroundEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'NTPCustomBackgroundEnabled', 
:dword, 
false,),
              "NTPMiddleSlotAnnouncementVisible" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'NTPMiddleSlotAnnouncementVisible', 
:dword, 
false,),
              "NativeMessagingUserLevelHosts" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'NativeMessagingUserLevelHosts', 
:dword, 
false,),
              "NetworkPredictionOptions" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'NetworkPredictionOptions', 
:dword, 
false,),
              "NetworkServiceSandboxEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'NetworkServiceSandboxEnabled', 
:dword, 
false,),
              "NewTabPageLocation" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'NewTabPageLocation', 
:string, 
false,),
              "OriginAgentClusterDefaultEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'OriginAgentClusterDefaultEnabled', 
:dword, 
false,),
              "PasswordDismissCompromisedAlertEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'PasswordDismissCompromisedAlertEnabled', 
:dword, 
false,),
              "PasswordLeakDetectionEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'PasswordLeakDetectionEnabled', 
:dword, 
false,),
              "PasswordManagerEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'PasswordManagerEnabled', 
:dword, 
false,),
              "PasswordProtectionChangePasswordURL" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PasswordProtectionChangePasswordURL', 
:string, 
false,),
              "PasswordProtectionWarningTrigger" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PasswordProtectionWarningTrigger', 
:dword, 
false,),
              "PaymentMethodQueryEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PaymentMethodQueryEnabled', 
:dword, 
false,),
              "PolicyAtomicGroupsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PolicyAtomicGroupsEnabled', 
:dword, 
false,),
              "PolicyRefreshRate" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PolicyRefreshRate', 
:dword, 
false,),
              "PrefixedStorageInfoEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrefixedStorageInfoEnabled', 
:dword, 
false,),
              "PrintHeaderFooter" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'PrintHeaderFooter', 
:dword, 
false,),
              "PrintPdfAsImageAvailability" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintPdfAsImageAvailability', 
:dword, 
false,),
              "PrintPostScriptMode" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintPostScriptMode', 
:dword, 
false,),
              "PrintPreviewUseSystemDefaultPrinter" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'PrintPreviewUseSystemDefaultPrinter', 
:dword, 
false,),
              "PrintRasterizationMode" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintRasterizationMode', 
:dword, 
false,),
              "PrintRasterizePdfDpi" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintRasterizePdfDpi', 
:dword, 
false,),
              "PrintingAllowedBackgroundGraphicsModes" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintingAllowedBackgroundGraphicsModes', 
:string, 
false,),
              "PrintingBackgroundGraphicsDefault" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintingBackgroundGraphicsDefault', 
:string, 
false,),
              "PrintingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintingEnabled', 
:dword, 
false,),
              "PrintingPaperSizeDefault" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PrintingPaperSizeDefault', 
:string, 
false,),
              "ProfilePickerOnStartupAvailability" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ProfilePickerOnStartupAvailability', 
:dword, 
false,),
              "PromotionalTabsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PromotionalTabsEnabled', 
:dword, 
false,),
              "PromptForDownloadLocation" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PromptForDownloadLocation', 
:dword, 
false,),
              "PromptOnMultipleMatchingCertificates" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'PromptOnMultipleMatchingCertificates', 
:dword, 
false,),
              "ProxySettings" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ProxySettings', 
:string, 
false,),
              "QuicAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'QuicAllowed', 
:dword, 
false,),
              "RelaunchNotification" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RelaunchNotification', 
:dword, 
false,),
              "RelaunchNotificationPeriod" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RelaunchNotificationPeriod', 
:dword, 
false,),
              "RelaunchWindow" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RelaunchWindow', 
:string, 
false,),
              "RemoteAccessHostAllowClientPairing" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostAllowClientPairing', 
:dword, 
false,),
              "RemoteAccessHostAllowFileTransfer" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostAllowFileTransfer', 
:dword, 
false,),
              "RemoteAccessHostAllowRelayedConnection" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostAllowRelayedConnection', 
:dword, 
false,),
              "RemoteAccessHostAllowRemoteAccessConnections" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostAllowRemoteAccessConnections', 
:dword, 
false,),
              "RemoteAccessHostAllowRemoteSupportConnections" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostAllowRemoteSupportConnections', 
:dword, 
false,),
              "RemoteAccessHostAllowUiAccessForRemoteAssistance" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostAllowUiAccessForRemoteAssistance', 
:dword, 
false,),
              "RemoteAccessHostClipboardSizeBytes" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostClipboardSizeBytes', 
:dword, 
false,),
              "RemoteAccessHostFirewallTraversal" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostFirewallTraversal', 
:dword, 
false,),
              "RemoteAccessHostMaximumSessionDurationMinutes" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostMaximumSessionDurationMinutes', 
:dword, 
false,),
              "RemoteAccessHostRequireCurtain" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostRequireCurtain', 
:dword, 
false,),
              "RemoteAccessHostUdpPortRange" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteAccessHostUdpPortRange', 
:string, 
false,),
              "RemoteDebuggingAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RemoteDebuggingAllowed', 
:dword, 
false,),
              "RendererAppContainerEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RendererAppContainerEnabled', 
:dword, 
false,),
              "RendererCodeIntegrityEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RendererCodeIntegrityEnabled', 
:dword, 
false,),
              "RequireOnlineRevocationChecksForLocalAnchors" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RequireOnlineRevocationChecksForLocalAnchors', 
:dword, 
false,),
              "RestoreOnStartup" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'RestoreOnStartup', 
:dword, 
false,),
              "RestrictSigninToPattern" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RestrictSigninToPattern', 
:string, 
false,),
              "RoamingProfileLocation" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RoamingProfileLocation', 
:string, 
false,),
              "RoamingProfileSupportEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'RoamingProfileSupportEnabled', 
:dword, 
false,),
              "SSLErrorOverrideAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SSLErrorOverrideAllowed', 
:dword, 
false,),
              "SSLVersionMin" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SSLVersionMin', 
:string, 
false,),
              "SafeBrowsingExtendedReportingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SafeBrowsingExtendedReportingEnabled', 
:dword, 
false,),
              "SafeBrowsingForTrustedSourcesEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'SafeBrowsingForTrustedSourcesEnabled', 
:dword, 
false,),
              "SafeBrowsingProtectionLevel" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'SafeBrowsingProtectionLevel', 
:dword, 
false,),
              "SafeSitesFilterBehavior" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SafeSitesFilterBehavior', 
:dword, 
false,),
              "SandboxExternalProtocolBlocked" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SandboxExternalProtocolBlocked', 
:dword, 
false,),
              "SavingBrowserHistoryDisabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SavingBrowserHistoryDisabled', 
:dword, 
false,),
              "ScreenCaptureAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ScreenCaptureAllowed', 
:dword, 
false,),
              "ScrollToTextFragmentEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ScrollToTextFragmentEnabled', 
:dword, 
false,),
              "SearchSuggestEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'SearchSuggestEnabled', 
:dword, 
false,),
              "SerialAllowUsbDevicesForUrls" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SerialAllowUsbDevicesForUrls', 
:string, 
false,),
              "SharedArrayBufferUnrestrictedAccessAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SharedArrayBufferUnrestrictedAccessAllowed', 
:dword, 
false,),
              "SharedClipboardEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SharedClipboardEnabled', 
:dword, 
false,),
              "ShoppingListEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ShoppingListEnabled', 
:dword, 
false,),
              "ShowAppsShortcutInBookmarkBar" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ShowAppsShortcutInBookmarkBar', 
:dword, 
false,),
              "ShowCastIconInToolbar" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ShowCastIconInToolbar', 
:dword, 
false,),
              "ShowFullUrlsInAddressBar" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ShowFullUrlsInAddressBar', 
:dword, 
false,),
              "ShowHomeButton" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'ShowHomeButton', 
:dword, 
false,),
              "SideSearchEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SideSearchEnabled', 
:dword, 
false,),
              "SignedHTTPExchangeEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SignedHTTPExchangeEnabled', 
:dword, 
false,),
              "SigninInterceptionEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SigninInterceptionEnabled', 
:dword, 
false,),
              "SitePerProcess" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SitePerProcess', 
:dword, 
false,),
              "SpellCheckServiceEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'SpellCheckServiceEnabled', 
:dword, 
false,),
              "SpellcheckEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SpellcheckEnabled', 
:dword, 
false,),
              "StrictMimetypeCheckForWorkerScriptsEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'StrictMimetypeCheckForWorkerScriptsEnabled', 
:dword, 
false,),
              "SuppressDifferentOriginSubframeDialogs" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SuppressDifferentOriginSubframeDialogs', 
:dword, 
false,),
              "SuppressUnsupportedOSWarning" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SuppressUnsupportedOSWarning', 
:dword, 
false,),
              "SyncDisabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'SyncDisabled', 
:dword, 
false,),
              "TaskManagerEndProcessEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'TaskManagerEndProcessEnabled', 
:dword, 
false,),
              "ThirdPartyBlockingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'ThirdPartyBlockingEnabled', 
:dword, 
false,),
              "TotalMemoryLimitMb" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'TotalMemoryLimitMb', 
:dword, 
false,),
              "TranslateEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'TranslateEnabled', 
:dword, 
false,),
              "UrlKeyedAnonymizedDataCollectionEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'UrlKeyedAnonymizedDataCollectionEnabled', 
:dword, 
false,),
              "UrlParamFilterEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'UrlParamFilterEnabled', 
:dword, 
false,),
              "UserAgentClientHintsGREASEUpdateEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'UserAgentClientHintsGREASEUpdateEnabled', 
:dword, 
false,),
              "UserAgentReduction" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'UserAgentReduction', 
:dword, 
false,),
              "UserDataDir" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'UserDataDir', 
:string, 
false,),
              "UserDataSnapshotRetentionLimit" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'UserDataSnapshotRetentionLimit', 
:dword, 
false,),
              "UserFeedbackAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'UserFeedbackAllowed', 
:dword, 
false,),
              "VideoCaptureAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'VideoCaptureAllowed', 
:dword, 
false,),
              "WPADQuickCheckEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WPADQuickCheckEnabled', 
:dword, 
false,),
              "WebAppInstallForceList" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebAppInstallForceList', 
:string, 
false,),
              "WebAppSettings" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebAppSettings', 
:string, 
false,),
              "WebHidAllowDevicesForUrls" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebHidAllowDevicesForUrls', 
:string, 
false,),
              "WebHidAllowDevicesWithHidUsagesForUrls" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebHidAllowDevicesWithHidUsagesForUrls', 
:string, 
false,),
              "WebRtcAllowLegacyTLSProtocols" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebRtcAllowLegacyTLSProtocols', 
:dword, 
false,),
              "WebRtcEventLogCollectionAllowed" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebRtcEventLogCollectionAllowed', 
:dword, 
false,),
              "WebRtcIPHandling" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebRtcIPHandling', 
:string, 
false,),
              "WebRtcUdpPortRange" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebRtcUdpPortRange', 
:string, 
false,),
              "WebSQLAccess" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebSQLAccess', 
:dword, 
false,),
              "WebSQLNonSecureContextEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebSQLNonSecureContextEnabled', 
:dword, 
false,),
              "WebUsbAllowDevicesForUrls" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WebUsbAllowDevicesForUrls', 
:string, 
false,),
              "WindowOcclusionEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'WindowOcclusionEnabled', 
:dword, 
false,),
              "AllHttpAuthSchemesAllowedForOrigins" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\AllHttpAuthSchemesAllowedForOrigins', 
nil, 
:string, 
true,),
              "AlternativeBrowserParameters" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\AlternativeBrowserParameters', 
nil, 
:string, 
true,),
              "AudioCaptureAllowedUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\AudioCaptureAllowedUrls', 
nil, 
:string, 
true,),
              "AutoOpenAllowedForURLs" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\AutoOpenAllowedForURLs', 
nil, 
:string, 
true,),
              "AutoOpenFileTypes" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\AutoOpenFileTypes', 
nil, 
:string, 
true,),
              "AutoSelectCertificateForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\AutoSelectCertificateForUrls', 
nil, 
:string, 
true,),
              "AutoplayAllowlist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\AutoplayAllowlist', 
nil, 
:string, 
true,),
              "BrowserSwitcherChromeParameters" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\BrowserSwitcherChromeParameters', 
nil, 
:string, 
true,),
              "BrowserSwitcherUrlGreylist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\BrowserSwitcherUrlGreylist', 
nil, 
:string, 
true,),
              "BrowserSwitcherUrlList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\BrowserSwitcherUrlList', 
nil, 
:string, 
true,),
              "CertificateTransparencyEnforcementDisabledForCas" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\CertificateTransparencyEnforcementDisabledForCas', 
nil, 
:string, 
true,),
              "CertificateTransparencyEnforcementDisabledForLegacyCas" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\CertificateTransparencyEnforcementDisabledForLegacyCas', 
nil, 
:string, 
true,),
              "CertificateTransparencyEnforcementDisabledForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\CertificateTransparencyEnforcementDisabledForUrls', 
nil, 
:string, 
true,),
              "ClearBrowsingDataOnExitList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ClearBrowsingDataOnExitList', 
nil, 
:string, 
true,),
              "ClipboardAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ClipboardAllowedForUrls', 
nil, 
:string, 
true,),
              "ClipboardBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ClipboardBlockedForUrls', 
nil, 
:string, 
true,),
              "CookiesAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\CookiesAllowedForUrls', 
nil, 
:string, 
true,),
              "CookiesBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\CookiesBlockedForUrls', 
nil, 
:string, 
true,),
              "CookiesSessionOnlyForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\CookiesSessionOnlyForUrls', 
nil, 
:string, 
true,),
              "DefaultSearchProviderAlternateURLs" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended\DefaultSearchProviderAlternateURLs', 
nil, 
:string, 
true,),
              "DefaultSearchProviderEncodings" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended\DefaultSearchProviderEncodings', 
nil, 
:string, 
true,),
              "EnableExperimentalPolicies" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\EnableExperimentalPolicies', 
nil, 
:string, 
true,),
              "ExplicitlyAllowedNetworkPorts" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExplicitlyAllowedNetworkPorts', 
nil, 
:string, 
true,),
              "ExtensionAllowedTypes" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionAllowedTypes', 
nil, 
:string, 
true,),
              "ExtensionInstallAllowlist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallAllowlist', 
nil, 
:string, 
true,),
              "ExtensionInstallBlocklist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist', 
nil, 
:string, 
true,),
              "ExtensionInstallForcelist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallForcelist', 
nil, 
:string, 
true,),
              "ExtensionInstallSources" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallSources', 
nil, 
:string, 
true,),
              "FileSystemReadAskForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\FileSystemReadAskForUrls', 
nil, 
:string, 
true,),
              "FileSystemReadBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\FileSystemReadBlockedForUrls', 
nil, 
:string, 
true,),
              "FileSystemWriteAskForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\FileSystemWriteAskForUrls', 
nil, 
:string, 
true,),
              "FileSystemWriteBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\FileSystemWriteBlockedForUrls', 
nil, 
:string, 
true,),
              "ForcedLanguages" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ForcedLanguages', 
nil, 
:string, 
true,),
              "HSTSPolicyBypassList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\HSTSPolicyBypassList', 
nil, 
:string, 
true,),
              "ImagesAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ImagesAllowedForUrls', 
nil, 
:string, 
true,),
              "ImagesBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ImagesBlockedForUrls', 
nil, 
:string, 
true,),
              "InsecureContentAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\InsecureContentAllowedForUrls', 
nil, 
:string, 
true,),
              "InsecureContentBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\InsecureContentBlockedForUrls', 
nil, 
:string, 
true,),
              "InsecurePrivateNetworkRequestsAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\InsecurePrivateNetworkRequestsAllowedForUrls', 
nil, 
:string, 
true,),
              "JavaScriptAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\JavaScriptAllowedForUrls', 
nil, 
:string, 
true,),
              "JavaScriptBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\JavaScriptBlockedForUrls', 
nil, 
:string, 
true,),
              "JavaScriptJitAllowedForSites" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\JavaScriptJitAllowedForSites', 
nil, 
:string, 
true,),
              "JavaScriptJitBlockedForSites" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\JavaScriptJitBlockedForSites', 
nil, 
:string, 
true,),
              "LegacySameSiteCookieBehaviorEnabledForDomainList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\LegacySameSiteCookieBehaviorEnabledForDomainList', 
nil, 
:string, 
true,),
              "LocalFontsAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\LocalFontsAllowedForUrls', 
nil, 
:string, 
true,),
              "LocalFontsBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\LocalFontsBlockedForUrls', 
nil, 
:string, 
true,),
              "LookalikeWarningAllowlistDomains" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\LookalikeWarningAllowlistDomains', 
nil, 
:string, 
true,),
              "NativeMessagingAllowlist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\NativeMessagingAllowlist', 
nil, 
:string, 
true,),
              "NativeMessagingBlocklist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\NativeMessagingBlocklist', 
nil, 
:string, 
true,),
              "NotificationsAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\NotificationsAllowedForUrls', 
nil, 
:string, 
true,),
              "NotificationsBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\NotificationsBlockedForUrls', 
nil, 
:string, 
true,),
              "OverrideSecurityRestrictionsOnInsecureOrigin" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\OverrideSecurityRestrictionsOnInsecureOrigin', 
nil, 
:string, 
true,),
              "PasswordProtectionLoginURLs" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\PasswordProtectionLoginURLs', 
nil, 
:string, 
true,),
              "PolicyDictionaryMultipleSourceMergeList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\PolicyDictionaryMultipleSourceMergeList', 
nil, 
:string, 
true,),
              "PolicyListMultipleSourceMergeList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\PolicyListMultipleSourceMergeList', 
nil, 
:string, 
true,),
              "PopupsAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\PopupsAllowedForUrls', 
nil, 
:string, 
true,),
              "PopupsBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\PopupsBlockedForUrls', 
nil, 
:string, 
true,),
              "PrinterTypeDenyList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\PrinterTypeDenyList', 
nil, 
:string, 
true,),
              "RemoteAccessHostClientDomainList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\RemoteAccessHostClientDomainList', 
nil, 
:string, 
true,),
              "RemoteAccessHostDomainList" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\RemoteAccessHostDomainList', 
nil, 
:string, 
true,),
              "RestoreOnStartupURLs" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended\RestoreOnStartupURLs', 
nil, 
:string, 
true,),
              "SSLErrorOverrideAllowedForOrigins" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SSLErrorOverrideAllowedForOrigins', 
nil, 
:string, 
true,),
              "SafeBrowsingAllowlistDomains" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SafeBrowsingAllowlistDomains', 
nil, 
:string, 
true,),
              "SameOriginTabCaptureAllowedByOrigins" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SameOriginTabCaptureAllowedByOrigins', 
nil, 
:string, 
true,),
              "ScreenCaptureAllowedByOrigins" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ScreenCaptureAllowedByOrigins', 
nil, 
:string, 
true,),
              "SecurityKeyPermitAttestation" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SecurityKeyPermitAttestation', 
nil, 
:string, 
true,),
              "SensorsAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SensorsAllowedForUrls', 
nil, 
:string, 
true,),
              "SensorsBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SensorsBlockedForUrls', 
nil, 
:string, 
true,),
              "SerialAllowAllPortsForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SerialAllowAllPortsForUrls', 
nil, 
:string, 
true,),
              "SerialAskForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SerialAskForUrls', 
nil, 
:string, 
true,),
              "SerialBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SerialBlockedForUrls', 
nil, 
:string, 
true,),
              "SpellcheckLanguage" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SpellcheckLanguage', 
nil, 
:string, 
true,),
              "SpellcheckLanguageBlocklist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SpellcheckLanguageBlocklist', 
nil, 
:string, 
true,),
              "SyncTypesListDisabled" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\SyncTypesListDisabled', 
nil, 
:string, 
true,),
              "TabCaptureAllowedByOrigins" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\TabCaptureAllowedByOrigins', 
nil, 
:string, 
true,),
              "TabDiscardingExceptions" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\TabDiscardingExceptions', 
nil, 
:string, 
true,),
              "URLAllowlist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLAllowlist', 
nil, 
:string, 
true,),
              "URLBlocklist" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\URLBlocklist', 
nil, 
:string, 
true,),
              "VideoCaptureAllowedUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\VideoCaptureAllowedUrls', 
nil, 
:string, 
true,),
              "WebHidAllowAllDevicesForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WebHidAllowAllDevicesForUrls', 
nil, 
:string, 
true,),
              "WebHidAskForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WebHidAskForUrls', 
nil, 
:string, 
true,),
              "WebHidBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WebHidBlockedForUrls', 
nil, 
:string, 
true,),
              "WebRtcLocalIpsAllowedUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WebRtcLocalIpsAllowedUrls', 
nil, 
:string, 
true,),
              "WebUsbAskForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WebUsbAskForUrls', 
nil, 
:string, 
true,),
              "WebUsbBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WebUsbBlockedForUrls', 
nil, 
:string, 
true,),
              "WindowCaptureAllowedByOrigins" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WindowCaptureAllowedByOrigins', 
nil, 
:string, 
true,),
              "WindowPlacementAllowedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WindowPlacementAllowedForUrls', 
nil, 
:string, 
true,),
              "WindowPlacementBlockedForUrls" => WindowsChromeIterableSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\WindowPlacementBlockedForUrls', 
nil, 
:string, 
true,),
              "DefaultDownloadDirectory" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'DefaultDownloadDirectory', 
:string, 
false,),
              "PrintPdfAsImageDefault" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'PrintPdfAsImageDefault', 
:dword, 
false,),
              "RegisteredProtocolHandlers" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\Recommended', 
'RegisteredProtocolHandlers', 
:string, 
false,),
              "CloudReportingEnabled" => WindowsChromeFlatSetting.new(
'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome', 
'CloudReportingEnabled', 
:dword, 
false,),
            }.freeze
    end
  end
end
# rubocop:enable Metrics/LineLength
