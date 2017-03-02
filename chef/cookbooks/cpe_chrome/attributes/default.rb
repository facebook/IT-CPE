#
# Cookbook Name:: cpe_chrome
# Attributes:: default
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
# Google Chrome & Chrome Canary attributes
# See https://www.chromium.org/administrators/policy-list-3

default['cpe_chrome']['profile'] = {
  'ExtensionInstallForcelist' => [],
  'ExtensionInstallBlacklist' => [],
  'EnabledPlugins' => [],
  'DisabledPlugins' => [],
  'DefaultPluginsSetting' => nil,
  'ExtensionInstallSources' => [],
  'PluginsAllowedForUrls' => [],
}

default['cpe_chrome']['mp'] = {
  'UseMasterPreferencesFile' => false,
  'FileContents' => [],
}
