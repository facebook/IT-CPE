# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8

# Cookbook Name:: cpe_crypt
# Resource:: cpe_crypt_configure
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#

# rubocop:disable Style/HashSyntax
resource_name :cpe_crypt_configure
provides :cpe_crypt_configure, :os => 'darwin'
default_action :manage

action_class do
  def crypt_mechanisms
    [
      'Crypt:Check,privileged',
      'Crypt:CryptGUI',
      'Crypt:Enablement,privileged',
    ].freeze
  end

  def crypt_currently_in_authdb(authdb_hash)
    if authdb_hash.nil?
      Chef::Log.warn('Security authorization db contained no value!')
      return false
    end
    # Crypt settings
    correct_mechanisms = Set.new(['loginwindow:done'] + crypt_mechanisms)
    existing_mechanisms = Set.new(authdb_hash['mechanisms'])
    # Return true if Crypt is present in the authdb settings
    correct_mechanisms.subset?(existing_mechanisms)
  end

  def add_crypt_to_authorizationdb
    remove = !node['cpe_crypt']['configure']
    # First, validate whether or not the current settings are correct
    # Get current settings from authdb
    current_authdb = Mixlib::ShellOut.new(
      '/usr/bin/security authorizationdb read system.login.console',
    ).run_command.stdout
    authdb_hash = Plist.parse_xml(current_authdb)
    if crypt_currently_in_authdb(authdb_hash) && !remove
      log('Authdb already configured for Crypt')
      return
    end
    # Remove any existing Crypt configs from system.login.console parse
    fixed_mechs =
      authdb_hash['mechanisms'].reject { |e| crypt_mechanisms.include? e }
    unless remove
      # Add the new Crypt mechanisms back into the authdb hash
      # These must go *AFTER* "loginwindow:done"
      crypt_index = fixed_mechs.index('loginwindow:done')
      fixed_mechs.insert(crypt_index + 1, crypt_mechanisms).flatten!
    end
    authdb_hash['mechanisms'] = fixed_mechs
    # Write settings back to disk
    # Send it back to security authorizationdb
    cmd = "echo \"#{Plist::Emit.dump(authdb_hash)}\" " +
          '| /usr/bin/security authorizationdb write system.login.console'
    execute 'security_authorizationdb_write' do
      command cmd
    end
  end

  def manage_crypt_prefs
    return unless node['cpe_crypt']['configure']
    organization = node['organization'] ? node['organization'] : 'Facebook'
    prefix = node['cpe_profiles']['prefix']
    prefs = node['cpe_crypt']['prefs'].reject { |_k, v| v.nil? }
    return if prefs.empty?
    node.default['cpe_profiles']["#{prefix}.crypt"] = {
      'PayloadIdentifier'        => "#{prefix}.crypt",
      'PayloadRemovalDisallowed' => true,
      'PayloadScope'             => 'System',
      'PayloadType'              => 'Configuration',
      'PayloadUUID'              => 'a3f3dc40-1fde-0131-31d5-000c2944c108',
      'PayloadOrganization'      => organization,
      'PayloadVersion'           => 1,
      'PayloadDisplayName'       => 'Crypt',
      'PayloadContent'           => [
        {
          'PayloadType'        => 'com.apple.ManagedClient.preferences',
          'PayloadVersion'     => 1,
          'PayloadIdentifier'  => "#{prefix}.crypt",
          'PayloadUUID'        => '7059fe60-222f-0131-31db-000c2944c108',
          'PayloadEnabled'     => true,
          'PayloadDisplayName' => 'Crypt',
          'PayloadContent'     => {
            'com.grahamgilbert.crypt' => {
              'Forced' => [
                {
                  'mcx_preference_settings' => prefs,
                },
              ],
            },
          },
        },
      ],
    }
  end
end

action :manage do
  add_crypt_to_authorizationdb
  manage_crypt_prefs
end
