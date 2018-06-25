# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8

# Cookbook Name:: cpe_munki
# Resource:: cpe_munki_local
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

require 'plist'
require 'json'

resource_name :cpe_munki_local
default_action :run

action :run do
  locals_exist = node['cpe_munki']['local']['managed_installs'].any? ||
                node['cpe_munki']['local']['managed_uninstalls'].any? ||
                node['cpe_munki']['local']['optional_installs'].any?

  return unless locals_exist
  return unless ::File.exist?('/usr/local/munki/managedsoftwareupdate')

  # If local only manifest preference is not set,
  # set it to the default 'extra_packages'
  unless node['cpe_munki']['preferences'].key?('LocalOnlyManifest')
    node.default['cpe_munki']['preferences']['LocalOnlyManifest'] =
      'extra_packages'
  end

  @catalog_items = parse_items_in_catalogs

  local_manifest = node['cpe_munki']['preferences']['LocalOnlyManifest']
  file "/Library/Managed Installs/manifests/#{local_manifest}" do # ~FC005
    content gen_plist
  end

  file '/Library/Managed Installs/manifests/SelfServeManifest' do
    not_if { node['cpe_munki']['local']['managed_uninstalls'].empty? }
    only_if do
      ::File.exist?('/Library/Managed Installs/manifests/SelfServeManifest')
    end
    content gen_selfservice_plist
  end

  # This file is for context for users to know whats avalible for their machine
  pretty_json = JSON.pretty_generate(@catalog_items)
  file '/Library/Managed Installs/munki_catalog_items.json' do
    content pretty_json.to_s
  end
end

def validate_install_array(install_array)
  catalog_items = parse_items_in_catalogs
  return install_array if catalog_items.empty?
  ret = []
  install_array.uniq.each do |item|
    ret << item if catalog_items.include?(item)
  end
  ret.uniq.sort
end

def gen_plist
  installs = validate_install_array(
    node['cpe_munki']['local']['managed_installs'],
  )
  uninstalls = validate_install_array(
    node['cpe_munki']['local']['managed_uninstalls'],
  )
  optional = validate_install_array(
    node['cpe_munki']['local']['optional_installs'],
  )
  plist_hash = {
    'managed_installs' => installs,
    'managed_uninstalls' => uninstalls,
    'optional_installs' => optional,
  }
  ::Chef::Log.info("cpe_munki_local: Managed installs: #{installs}")
  Plist::Emit.dump(plist_hash) unless plist_hash.nil?
end

def gen_selfservice_plist
  self_serve_file = '/Library/Managed Installs/manifests/SelfServeManifest'
  return nil unless ::File.exist?(self_serve_file)
  ss_manifest = read_plist(self_serve_file)
  uninstalls = validate_install_array(
    node['cpe_munki']['local']['managed_uninstalls'],
  )
  # remove uninstalls from ss_manifest array
  ss_manifest['managed_installs'] =
    ss_manifest['managed_installs'] - uninstalls

  ::Chef::Log.info(
    "cpe_munki_local: Cleanup Self Service: #{uninstalls}",
  )
  Plist::Emit.dump(ss_manifest)
end

def read_plist(xml_file)
  Plist.parse_xml(xml_file)
end

def parse_items_in_catalogs
  catalogs = []
  catlogs_dir = '/Library/Managed Installs/catalogs/'
  Dir.foreach(catlogs_dir) do |catalog|
    next if ['.', '..'].include?(catalog)
    begin
      p = read_plist(catlogs_dir + catalog)
      p.each do |d|
        catalogs << d['name']
      end
    rescue StandardError
      next
    end
  end
  catalogs.uniq
rescue StandardError
  []
end

