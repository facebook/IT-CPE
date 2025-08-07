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

# Cookbook Name:: cpe_munki
# Resource:: cpe_munki_local

require 'plist'
require 'json'

resource_name :cpe_munki_local
provides :cpe_munki_local, :os => 'darwin'
unified_mode(false) if Chef::VERSION >= 18
default_action :run

action :run do
  # Managed local manifest if local installs/uninstalls or LocalOnlyManifest
  # attributes are set
  manage_locals = (
    (node['cpe_munki']['local']['managed_installs'].any? ||
    node['cpe_munki']['local']['managed_uninstalls'].any?) ||
    !node['cpe_munki']['preferences']['LocalOnlyManifest'].nil?
  )

  return unless manage_locals
  return unless ::File.exist?('/usr/local/munki/managedsoftwareupdate')

  # If local only manifest preference is not set,
  # set it to the default 'extra_packages'
  if node['cpe_munki']['preferences']['LocalOnlyManifest'].nil?
    node.default['cpe_munki']['preferences']['LocalOnlyManifest'] =
      'extra_packages'
  end

  @catalog_items = parse_items_in_catalogs

  local_manifest = node['cpe_munki']['preferences']['LocalOnlyManifest']
  file "/Library/Managed Installs/manifests/#{local_manifest}" do
    owner node.root_user
    group 'wheel'
    mode '644'
    content gen_plist
  end

  file '/Library/Managed Installs/manifests/SelfServeManifest' do
    not_if { node['cpe_munki']['local']['managed_uninstalls'].empty? }
    only_if do
      ::File.exist?('/Library/Managed Installs/manifests/SelfServeManifest')
    end
    owner node.root_user
    group 'wheel'
    mode '644'
    content gen_selfservice_plist
  end

  # This file is for context for users to know what's available for their machine
  pretty_json = JSON.pretty_generate(@catalog_items)
  file '/Library/Managed Installs/munki_catalog_items.json' do
    owner node.root_user
    group 'wheel'
    mode '644'
    content pretty_json.to_s
  end
end

def validate_install_array(install_array)
  catalog_items = parse_items_in_catalogs
  install_array = FB::Helpers.evaluate_lazy_enumerable(install_array.to_a).compact
  return install_array if catalog_items.empty?
  ret = []
  install_array.uniq.each do |item|
    item_no_ver = item.split('-')[0] # strip version component of item
    if catalog_items.any? { |entry| entry == item_no_ver || entry == item }
      ret << item
    else
      ::Chef::Log.warn(
        "#{cookbook_name}: item not found in catalogs: #{item}",
      )
    end
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
  optionals = validate_install_array(
    node['cpe_munki']['local']['optional_installs'],
  )

  # Check for common elements in installs and uninstalls
  common_elements = installs & uninstalls
  if !common_elements.empty?
    ::Chef::Log.warn(
      "#{cookbook_name}: Found #{common_elements.size} items that are both
      marked for install and uninstall: #{common_elements.join(', ')}. Common elements removed from installs
      as uninstalls take precedence.",
    )
  end

  # Remove elements from installs that are present in uninstalls
  installs -= uninstalls

  plist_hash = {
    'managed_installs' => installs,
    'managed_uninstalls' => uninstalls,
    'optional_installs' => optionals,
  }
  ::Chef::Log.info("#{cookbook_name}: Managed installs: #{installs}")
  unless optionals.empty?
    ::Chef::Log.info("#{cookbook_name}: Optional installs: #{optionals}")
  end
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
    "#{cookbook_name}: Cleanup Self Service: #{uninstalls}",
  )
  Plist::Emit.dump(ss_manifest)
end

def read_plist(xml_file)
  Plist.parse_xml(xml_file)
end

def parse_items_in_catalogs
  catalogs = []
  catalogs_dir = '/Library/Managed Installs/catalogs/'
  Dir.foreach(catalogs_dir) do |catalog|
    next if ['.', '..'].include?(catalog)
    begin
      p = read_plist(catalogs_dir + catalog)
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
