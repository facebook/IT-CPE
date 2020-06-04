cpe_adobe_flash Cookbook
========================
Manage Adobe Flash settings for macOS and Windows.

Requirements
------------
* macOS
* Windows

Attributes
----------
* node['cpe_adobe_flash']['configure']
* node['cpe_adobe_flash']['uninstall']
* node['cpe_adobe_flash']['configs']['AllowUserLocalTrust']
* node['cpe_adobe_flash']['configs']['AssetCacheSize']
* node['cpe_adobe_flash']['configs']['AutoUpdateDisable']
* node['cpe_adobe_flash']['configs']['AutoUpdateInterval']
* node['cpe_adobe_flash']['configs']['AVHardwareDisable']
* node['cpe_adobe_flash']['configs']['AVHardwareEnabledDomain']
* node['cpe_adobe_flash']['configs']['DisableDeviceFontEnumeration']
* node['cpe_adobe_flash']['configs']['DisableHardwareAcceleration']
* node['cpe_adobe_flash']['configs']['DisableNetworkAndFilesystemInHostApp']
* node['cpe_adobe_flash']['configs']['DisableProductDownload']
* node['cpe_adobe_flash']['configs']['DisableSockets']
* node['cpe_adobe_flash']['configs']['EnableSocketsTo']
* node['cpe_adobe_flash']['configs']['EnforceLocalSecurityInActiveXHostApp']
* node['cpe_adobe_flash']['configs']['FileDownloadDisable']
* node['cpe_adobe_flash']['configs']['FileDownloadEnabledDomain']
* node['cpe_adobe_flash']['configs']['FileUploadDisable']
* node['cpe_adobe_flash']['configs']['FileUploadEnabledDomain']
* node['cpe_adobe_flash']['configs']['FullScreenDisable']
* node['cpe_adobe_flash']['configs']['LegacyDomainMatching']
* node['cpe_adobe_flash']['configs']['LocalFileLegacyAction']
* node['cpe_adobe_flash']['configs']['LocalFileReadDisable']
* node['cpe_adobe_flash']['configs']['EnableInsecureLocalWithFileSystem']
* node['cpe_adobe_flash']['configs']['LocalStorageLimit']
* node['cpe_adobe_flash']['configs']['OverrideGPUValidation']
* node['cpe_adobe_flash']['configs']['ProductDisabled']
* node['cpe_adobe_flash']['configs']['ProtectedMode']
* node['cpe_adobe_flash']['configs']['ProtectedModeBrokerAllowlistConfigFile']
* node['cpe_adobe_flash']['configs']['ProtectedModeBrokerLogfilePath']
* node['cpe_adobe_flash']['configs']['RTMFPP2PDisable']
* node['cpe_adobe_flash']['configs']['RTMFPTURNProxy']
* node['cpe_adobe_flash']['configs']['SilentAutoUpdateEnable']
* node['cpe_adobe_flash']['configs']['SilentAutoUpdateServerDomain']
* node['cpe_adobe_flash']['configs']['SilentAutoUpdateVerboseLogging']
* node['cpe_adobe_flash']['configs']['ThirdPartyStorage']
* node['cpe_adobe_flash']['configs']['UseWAVPlayer']
* node['cpe_adobe_flash']['configs']['NetworkRequestTimeout']
* node['cpe_adobe_flash']['configs']['EnableInsecureJunctionBehavior']
* node['cpe_adobe_flash']['configs']['EnableLocalAppData']
* node['cpe_adobe_flash']['configs']['DefaultLanguage']

Usage
-----
The cookbook will manage the `mms.cfg` config file. You can find the available
configs on Adobe's [Administration Guide](https://helpx.adobe.com/flash-player/kb/administration-configure-auto-update-notification.html).

Set `['cpe_adobe_flash']['configure']` to `true` to manage the `mms.cfg` file.

Set `['cpe_adobe_flash']['uninstall']` to `true` to remove Adobe Flash in the
event of a zero Day. On macOS, this will remove each and every file, as well
as attempt to uninstall via Munki. On Windows, this will only attempt to
uninstall via Chocolatey.

Example:

```
{
  'configure' => false,
  'uninstall' => true,
}.each { |k, v| node.default['cpe_adobe_flash'][k] = v }

{
  'AutoUpdateDisable' => 0,
  'SilentAutoUpdateEnable' => 1,
  'SilentAutoUpdateVerboseLogging' => 1,
}.each { |k, v| node.default['cpe_adobe_flash']['configs'][k] = v }
```
