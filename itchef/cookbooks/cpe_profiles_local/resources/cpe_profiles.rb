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

# Cookbook Name:: cpe_profiles_local
# Resource:: cpe_profiles_local

resource_name :cpe_profiles_local
provides :cpe_profiles_local, :os => 'darwin'
default_action :run

action :run do
  node['cpe_profiles_local'].to_hash.values.each do |profile|
    next if profile.is_a?(String) &&
      profile.match(node['cpe_profiles_local']['prefix'])
    identifier = process_identifier(profile)
    osx_profiles_resource(identifier, 'install', profile)
  end
end

action :clean_up do
  process_profile_cleanup_identifiers
  return if node['cpe_profiles_local']['__cleanup'].nil?
  node['cpe_profiles_local']['__cleanup'].each do |identifier|
    osx_profiles_resource(identifier, 'remove', nil)
  end
end

action_class do
  def process_identifier(profile)
    identifier = profile['PayloadIdentifier']
    unless identifier.start_with?(node['cpe_profiles_local']['prefix'])
      error_string = "#{identifier} is an invalid profile identifier. The" +
           "identifier must start with #{node['cpe_profiles_local']['prefix']}!"
      fail Chef::Exceptions::ConfigurationError, error_string
    end
    identifier
  end

  def osx_profiles_resource(identifier, nr_action, nr_profile)
    return unless identifier
    with_run_context :root do
      osx_profile identifier do
        profile nr_profile unless nr_profile.nil?
        action nr_action
      end
    end
  end

  def find_managed_profile_identifiers
    managed_identifiers = []
    node['cpe_profiles_local']&.to_hash&.values&.each do |profile|
      managed_identifiers << profile['PayloadIdentifier']
    end
    current_identifiers = []
    profiles_string = shell_out!('profiles -P -o stdout-xml')
    profiles = Plist.parse_xml(profiles_string.stdout)
    profiles['_computerlevel']&.each do |profile|
      if profile['ProfileIdentifier'].start_with?(
        node['cpe_profiles_local']['prefix'],
      )
        current_identifiers << profile['ProfileIdentifier']
      end
    end
    return managed_identifiers, current_identifiers
  end

  def append_to_cleanup(identifier)
    node.default['cpe_profiles_local']['__cleanup'] = [] unless
      node['cpe_profiles_local']['__cleanup']
    node.default['cpe_profiles_local']['__cleanup'] << identifier
  end

  def process_profile_cleanup_identifiers
    managed_identifiers, current_identifiers = find_managed_profile_identifiers
    return if current_identifiers.empty?
    current_identifiers.each do |identifier|
      unless managed_identifiers.include?(identifier) ||
             append_to_cleanup(identifier)
      end
    end
  end
end
