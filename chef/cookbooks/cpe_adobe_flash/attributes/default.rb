#
# Cookbook Name:: cpe_adobe_flash
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

default['cpe_adobe_flash'] = {
  'configure' => false,
  'uninstall' => false,
  'MinimumUpgradeVersion' => nil,
  'configs' => {
    'AllowUserLocalTrust' => nil,
    'AssetCacheSize' => nil,
    'AutoUpdateDisable' => nil,
    'AutoUpdateInterval' => nil,
    'AVHardwareDisable' => nil,
    'AVHardwareEnabledDomain' => nil,
    'DisableDeviceFontEnumeration' => nil,
    'DisableHardwareAcceleration' => nil,
    'DisableNetworkAndFilesystemInHostApp' => nil,
    'DisableProductDownload' => nil,
    'DisableSockets' => nil,
    'EnableSocketsTo' => nil,
    'EnforceLocalSecurityInActiveXHostApp' => nil,
    'FileDownloadDisable' => nil,
    'FileDownloadEnabledDomain' => nil,
    'FileUploadDisable' => nil,
    'FileUploadEnabledDomain' => nil,
    'FullScreenDisable' => nil,
    'LegacyDomainMatching' => nil,
    'LocalFileLegacyAction' => nil,
    'LocalFileReadDisable' => nil,
    'EnableInsecureLocalWithFileSystem' => nil,
    'LocalStorageLimit' => nil,
    'OverrideGPUValidation' => nil,
    'ProductDisabled' => nil,
    'ProtectedMode' => nil,
    'ProtectedModeBrokerWhitelistConfigFile' => nil,
    'ProtectedModeBrokerLogfilePath' => nil,
    'RTMFPP2PDisable' => nil,
    'RTMFPTURNProxy' => nil,
    'SilentAutoUpdateEnable' => nil,
    'SilentAutoUpdateServerDomain' => nil,
    'SilentAutoUpdateVerboseLogging' => nil,
    'ThirdPartyStorage' => nil,
    'UseWAVPlayer' => nil,
    'NetworkRequestTimeout' => nil,
    'EnableInsecureJunctionBehavior' => nil,
    'EnableLocalAppData' => nil,
    'DefaultLanguage' => nil,
    'EventJitterMicroseconds' => nil,
    'TimerJitterMicroseconds' => nil,
    'InsecureJitterDisabledDomain' => nil,
  },
}
