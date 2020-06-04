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

# Cookbook Name:: cpe_adobe_flash
# Attributes:: default

default['cpe_adobe_flash'] = {
  'configure' => false,
  'uninstall' => false,
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
    'ProtectedModeBrokerAllowlistConfigFile' => nil,
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
  },
}
