# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_office
# Resources:: darwin
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_office_darwin
provides :cpe_office_darwin, :os => 'darwin'
default_action :manage

action :manage do
  o365_prefs = node['cpe_office']['mac']['o365'].reject { |_k, v| v.nil? }
  onenote_prefs = node['cpe_office']['mac']['onenote'].reject { |_k, v| v.nil? }
  excel_prefs = node['cpe_office']['mac']['excel'].reject { |_k, v| v.nil? }
  outlook_prefs = node['cpe_office']['mac']['outlook'].reject { |_k, v| v.nil? }
  ppt_prefs = node['cpe_office']['mac']['powerpoint'].reject { |_k, v| v.nil? }
  word_prefs = node['cpe_office']['mac']['word'].reject { |_k, v| v.nil? }

  if [
    o365_prefs,
    onenote_prefs,
    excel_prefs,
    outlook_prefs,
    ppt_prefs,
    word_prefs,
  ].all?(&:empty?)
    Chef::Log.info("#{cookbook_name}: prefs not found.")
    return
  end

  unless o365_prefs.empty?
    {
      'PayloadEnabled' => true,
      'PayloadIdentifier' => 'cbf07457-37c7-4dc1-8338-a7a0931c92d2',
      'PayloadDescription' => 'Office 365 Telemetry',
      'PayloadVersion' => 1,
      'PayloadType' => 'com.microsoft.Office365ServiceV2',
      'PayloadUUID' => 'cbf07457-37c7-4dc1-8338-a7a0931c92d2',
    }.each { |k, v| o365_prefs[k] = v }
  end

  unless onenote_prefs.empty?
    {
      'PayloadEnabled' => true,
      'PayloadIdentifier' => '6b670a4b-a113-4022-b35d-44c832d00f9b',
      'PayloadDescription' => 'Microsoft OneNote Settings',
      'PayloadVersion' => 1,
      'PayloadType' => 'com.microsoft.onenote.mac',
      'PayloadUUID' => '6b670a4b-a113-4022-b35d-44c832d00f9b',
    }.each { |k, v| onenote_prefs[k] = v }
  end

  unless excel_prefs.empty?
    {
      'PayloadEnabled' => true,
      'PayloadIdentifier' => '1dc948b7-29c5-4d17-a3ab-75d2979b9a4a',
      'PayloadDescription' => 'Microsoft Excel Settings',
      'PayloadVersion' => 1,
      'PayloadType' => 'com.microsoft.Excel',
      'PayloadUUID' => '1dc948b7-29c5-4d17-a3ab-75d2979b9a4a',
    }.each { |k, v| excel_prefs[k] = v }
  end

  unless outlook_prefs.empty?
    {
      'PayloadEnabled' => true,
      'PayloadIdentifier' => '6b640559-d6b3-4efd-876f-d4234c404d53',
      'PayloadDescription' => 'Microsoft Outlook Settings',
      'PayloadVersion' => 1,
      'PayloadType' => 'com.microsoft.Outlook',
      'PayloadUUID' => '6b640559-d6b3-4efd-876f-d4234c404d53',
    }.each { |k, v| outlook_prefs[k] = v }
  end

  unless ppt_prefs.empty?
    {
      'PayloadEnabled' => true,
      'PayloadIdentifier' => '485050ab-187e-49db-9404-3c81bac94825',
      'PayloadDescription' => 'Microsoft PowerPoint Settings',
      'PayloadVersion' => 1,
      'PayloadType' => 'com.microsoft.Powerpoint',
      'PayloadUUID' => '485050ab-187e-49db-9404-3c81bac94825',
    }.each { |k, v| ppt_prefs[k] = v }
  end

  unless word_prefs.empty?
    {
      'PayloadEnabled' => true,
      'PayloadIdentifier' => 'd2469e99-8398-40f5-b05f-8f56fa3b7405',
      'PayloadDescription' => 'Microsoft Word Settings',
      'PayloadVersion' => 1,
      'PayloadType' => 'com.microsoft.Word',
      'PayloadUUID' => 'd2469e99-8398-40f5-b05f-8f56fa3b7405',
    }.each { |k, v| word_prefs[k] = v }
  end

  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] || 'Facebook'

  profile = {
    'PayloadEnabled' => true,
    'PayloadDisplayName' => 'Microsoft Office',
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadRemovalDisallowed' => true,
    'PayloadDescription' => '',
    'PayloadVersion' => 1,
    'PayloadOrganization' => organization,
    'PayloadIdentifier' => "#{prefix}.office",
    'PayloadUUID' => '17ac8170-9515-4f50-95f5-410c7f46797d',
    'PayloadContent' => [],
  }

  [
    o365_prefs,
    onenote_prefs,
    excel_prefs,
    outlook_prefs,
    ppt_prefs,
    word_prefs,
  ].each do |prefs|
    profile['PayloadContent'] << prefs unless prefs.empty?
  end

  profile_domain = "#{node['cpe_profiles']['prefix']}.office"
  node.default['cpe_profiles'][profile_domain] = profile
end
