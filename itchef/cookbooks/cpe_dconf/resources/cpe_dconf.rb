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

# Cookbook Name:: cpe_dconf
# Resource:: default

resource_name :cpe_dconf
provides :cpe_dconf, :os => 'linux'
default_action :update

action :update do
  return unless node['cpe_dconf']['settings'].values.any?

  # Make sure dconf cli package is up-to-date
  dconf_cli_pkg = value_for_platform_family(
    'debian' => 'dconf-cli',
    :default => 'dconf',
  )
  package dconf_cli_pkg do
    action :upgrade
  end

  # Set directory permissions
  %w{
    /etc/dconf
    /etc/dconf/profile
    /etc/dconf/db
    /etc/dconf/db/cpe.d
    /etc/dconf/db/cpe.d/locks
  }.each do |dir|
    directory dir do
      owner 'root'
      group 'root'
      mode '0755'
    end
  end

  # Install dconf user profile
  cookbook_file '/etc/dconf/profile/user' do
    source 'dconf-user-profile'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'execute[update dconf]', :delayed
  end

  # Configure dconf keys for each component
  dconf_db_dir = '/etc/dconf/db/cpe.d'
  node['cpe_dconf']['settings'].each do |comp, settings_raw|
    # Here, each key can correspond to either a primitive (like a string), where
    # we assume lock=true, or it can be a hash, in order to disable locking.
    # This step will process settings to determien the lock status for each key.
    settings_processed = {}
    locks = []
    settings_raw.each do |dir, keys|
      settings_processed[dir] = {}
      keys.each do |k, v|
        if v.respond_to?(:key)
          # Replace hash with literal for use in template
          settings_processed[dir][k] = v['value']
          lock = v.fetch('lock', true)
        else
          # Use literal value and assume lock=true
          settings_processed[dir][k] = v
          lock = true
        end

        # Build list of keys to lock, to be used later
        if lock
          locks.push "/#{dir}/#{k}"
        end
      end
    end

    # Generate keys file
    template ::File.join(dconf_db_dir, comp) do
      source 'dconf-generic-keys.erb'
      owner 'root'
      group 'root'
      mode '0644'
      notifies :run, 'execute[update dconf]', :delayed
      variables(
        :settings => settings_processed,
      )
    end

    # Generate locks file
    template ::File.join(dconf_db_dir, 'locks', comp) do # ~FB031
      source 'dconf-generic-locks.erb'
      owner 'root'
      group 'root'
      mode '0644'
      notifies :run, 'execute[update dconf]', :delayed
      variables(
        :locks => locks,
      )
    end
  end

  # clean up settings that no longer exist
  # gate on the directory existing, since this code runs
  # earlier than the resources actually creating the directories
  if ::Dir.exist?(dconf_db_dir)
    stale_dbs = ::Dir.entries(dconf_db_dir).select do |f|
      ::File.file?(::File.join(dconf_db_dir, f)) &&
      !node['cpe_dconf']['settings'].keys.include?(f)
    end

    stale_dbs.each do |db|
      file ::File.join(dconf_db_dir, db) do
        action :delete
        notifies :run, 'execute[update dconf]', :delayed
      end
    end
  end

  locks_dir = ::File.join(dconf_db_dir, 'locks')
  if ::Dir.exist?(locks_dir)
    stale_locks = ::Dir.entries(locks_dir).select do |f|
      ::File.file?(::File.join(locks_dir, f)) &&
      !node['cpe_dconf']['settings'].keys.include?(f)
    end

    stale_locks.each do |lock|
      file ::File.join(locks_dir, lock) do
        action :delete
        notifies :run, 'execute[update dconf]', :delayed
      end
    end
  end

  # Finally, notify dconf to rebuild its binary database from our files
  execute 'update dconf' do
    command '/usr/bin/dconf update'
    action :nothing
  end
end
