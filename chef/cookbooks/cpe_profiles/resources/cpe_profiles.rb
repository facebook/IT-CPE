#
# Cookbook Name:: cpe_profiles
# Resource:: cpe_profiles
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

resource_name :cpe_profiles
default_action :run

action :run do
  node['cpe_profiles'].to_hash.values.each do |profile|
    next if profile.is_a?(String) &&
      profile.match(node['cpe_profiles']['prefix'])
    identifier = process_identifier(profile)
    osx_profiles_resource(identifier, 'install', profile)
  end
end

action :clean_up do
  process_profile_cleanup_identifiers
  return if node['cpe_profiles']['__cleanup'].nil?
  node['cpe_profiles']['__cleanup'].each do |identifier|
    osx_profiles_resource(identifier, 'remove', nil)
  end
end

def query_installed_profiles_legacy
  # 10.7 has a bug where if you pass .plist it makes a second .plist.
  if node.os_less_than?('10.8')
    tempfile = ::Dir::Tmpname.create('stdout-xml') {}
  else
    tempfile = ::Dir::Tmpname.create('stdout-xml.plist') {}
  end
  # Dump all profile metadata to a tempfile
  shell_out!("profiles -P -o '#{tempfile}'")
  # 10.7 has a bug where if you pass .plist it makes a second .plist.
  if node.os_less_than?('10.8')
    installed_profiles = Plist.parse_xml(tempfile + '.plist')
  else
    installed_profiles = Plist.parse_xml(tempfile)
  end
  # Clean up the temp file as we do not need it anymore
  ::File.unlink(tempfile)
  installed_profiles
end

def process_identifier(profile)
  identifier = profile['PayloadIdentifier']
  unless identifier.start_with?(node['cpe_profiles']['prefix'])
    error_string = "#{identifier} is an invalid profile identifier. The" +
         "identifier must start with #{node['cpe_profiles']['prefix']}!"
    fail Chef::Exceptions::ConfigurationError, error_string
  end
  identifier
end

def osx_profiles_resource(identifier, action, profile)
  return unless identifier
  res = Chef::Resource::OsxProfile.new(identifier, run_context)
  unless profile.nil?
    res.send('profile', profile)
  end
  res.action(action)
  res.run_action action
  res
end

def find_managed_profile_identifiers
  managed_identifiers = []
  unless node['cpe_profiles'].nil?
    node['cpe_profiles'].to_hash.values.each do |profile|
      managed_identifiers << profile['PayloadIdentifier']
    end
  end
  current_identifiers = []
  if node.os_at_least?('10.13')
    profiles_string = shell_out!('profiles list -output stdout-xml')
  elsif node.os_at_least?('10.10')
    profiles_string = shell_out!('profiles -P -o stdout-xml')
  end
  # Take the profile content from stdout on 10.10 and higher
  if node.os_at_least?('10.10')
    profiles = Plist.parse_xml(profiles_string.stdout)
  else
    # 10.7 -> 10.9 require a legacy profile provider
    profiles = query_installed_profiles_legacy
  end
  if profiles['_computerlevel']
    profiles['_computerlevel'].each do |profile|
      if profile['ProfileIdentifier'].start_with?(
        node['cpe_profiles']['prefix'],
      )
        current_identifiers << profile['ProfileIdentifier']
      end
    end
  end
  return managed_identifiers, current_identifiers
end

def append_to_cleanup(identifier)
  node.default['cpe_profiles']['__cleanup'] = [] unless
    node['cpe_profiles']['__cleanup']
  node.default['cpe_profiles']['__cleanup'] << identifier
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
