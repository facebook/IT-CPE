#
# Cookbook Name:: cpe_preferencepanes
# Recipe:: default
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

resource_name :cpe_preferencepanes
default_action :config

action :config do
  prefs = node['cpe_preferencepanes'].reject { |_k, v| v.nil? }
  return if prefs.empty?
  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  DisabledPrefPanes = node['cpe_preferencepanes']['DisabledPreferencePanes']
  HiddenPreferencePanes = node['cpe_preferencepanes']['HiddenPreferencePanes']
  node.default['cpe_profiles']["#{prefix}.prefpanes"] = {
    'PayloadIdentifier' => "#{prefix}.prefpanes",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => 'E2R9I0K4-1C7F-4662-9921-GCE3RBK7E4BD',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Preference Panes',
    'PayloadContent' => [
      {
        'PayloadType' => 'com.apple.systempreferences',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.prefpanes",
        'PayloadUUID' => '77537A7B-76E2-4ED8-B559-A581002CFD3C',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Preference Panes',
        'DisabledPreferencePanes' => DisabledPrefPanes,
        'HiddenPreferencePanes' => HiddenPreferencePanes,
      },
    ],
  }
end
