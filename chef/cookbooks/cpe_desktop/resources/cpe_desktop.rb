#
# Cookbook Name:: cpe_desktop
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

resource_name :cpe_desktop
default_action :run

action :run do
  prefs = node['cpe_desktop'].reject { |_k, v| v.nil? }
  return if prefs.empty?
  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  override_picture_path = node['cpe_desktop']['override-picture-path']
  node.default['cpe_profiles']["#{prefix}.desktop"] = {
    'PayloadIdentifier' => "#{prefix}.desktop",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => '5450b6cb-83ef-56e5-65df-f3ba1af1ff6a',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Desktop',
    'PayloadContent' => [
      {
        'PayloadType' => 'com.apple.desktop',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.desktop",
        'PayloadUUID' => '4c390cb0-4832-0134-efbb-2c87a324f377',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Desktop',
        'locked' => true,
        'override-picture-path' => override_picture_path
      }
    ]
  }
end
