# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_safari
# Resources:: cpe_safari
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_safari
default_action :config

action :config do
  safari_prefs = node['cpe_safari'].reject { |_k, v| v.nil? }
  return if safari_prefs.empty?

  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  safari_profile = {
    'PayloadIdentifier' => "#{prefix}.browsers.safari",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => 'bf900530-2306-0131-32e2-000c2944c108',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Safari',
    'PayloadContent' => [],
  }
  unless safari_prefs.empty?
    safari_profile['PayloadContent'].push(
      'PayloadType' => 'com.apple.Safari',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.browsers.safari",
      'PayloadUUID' => '3377ead0-2310-0131-32ec-000c2944c108',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => 'Safari',
    )
    safari_prefs.keys.each do |key|
      next if safari_prefs[key].nil?
      safari_profile['PayloadContent'][0][key] = safari_prefs[key]
    end
  end

  node.default['cpe_profiles']["#{prefix}.browsers.safari"] = safari_profile
end
