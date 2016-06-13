# Cookbook Name:: custom_utils
# Library::node_functions
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  # Custom Extensions of the node object.
  class Node

    # Allows you to dig through the node's attributes but still get back an
    # arbitrary value in the event the key does not exist.
    # Adapted for Chef from discussion found here: https://fburl.com/229058197
    # 
    # @param path [required] [String] A string representing the path to search
    # for the key.
    # @param delim [opt] [String] A character that you will split the path on.
    # @param default [opt] [Object] An object to return if the key is not found.
    # @return [Object] Returns an arbitrary object in the event the key isn't
    # there. 
    # @note Returns nil by default
    # @note Returns the default value in the event of an exception
    # @example 
    #  irb> node.default.awesome = 'yup'
    #  => "yup"
    #  irb> node.dig('awesome/not_there')
    #  => nil
    #  irb> node.dig('awesome')
    #  => "yup"
    #  irb> node.override.not_cool = 'but still functional'
    #  => "but still functional"
    #  irb> node.dig('not_cool')
    #  => "but still functional"
    #  irb> node.dig('default_val', default: 'I get this back anyway')
    #  => "I get this back anyway"
    #  irb> node.automatic.a.very.deeply.nested.value = ':)'
    #  => ":)"
    #  irb> node.dig('a/very/deeply/nested/value')
    #  => ":)"
    def dig(path, delim: '/', default: nil)
      return default if path.nil?
      node_path = path.split(delim)
      node_path.inject(self) do |location, key|
        begin
          location.attribute?(key.to_s) ? location[key] : default
        rescue NoMethodError
          default
        end
      end
    end

    def console_user
      unless self.macos?
        Chef::Log.warn('node.console_user called on non-OS X!')
        return
      end
      usercmd = Mixlib::ShellOut.new(
        '/usr/bin/stat -f%Su /dev/console'
      ).run_command.stdout
      username = usercmd.chomp
      username
    end

    def serial
      unless self.macos?
        Chef::Log.warn('node.serial called on non-OS X!')
        return
      end
      return node['serial'] if node['serial']
      serial = Mixlib::ShellOut.new(
        '/usr/sbin/ioreg -c IOPlatformExpertDevice |head -30' +
        '|grep IOPlatformSerialNumber | awk \'{print $4}\' | sed -e s/\"//g'
      ).run_command.stdout.chomp
      node.default['serial'] = serial
      return serial
    end

    def uuid 
      unless macosx?
        Chef::Log.warn('node.serial called on non-OS X!')
        return
      end
      return node['uuid'] if node['uuid']
      uuid = Mixlib::ShellOut.new(
        '/usr/sbin/system_profiler SPHardwareDataType' +
        '| awk \'/UUID/ { print $3; }\''
      ).run_command.stdout.chomp
      node.default['uuid'] = uuid
      return uuid
    end

   def get_shard(serial: nil, salt: nil, chunks: 100)
      # grab the serial by platform if possible
      # return nil if not possible
      serial = serial ? serial : node.serial
      serial = node.uuid if serial.nil?
      return 0 if serial.nil?
      if salt
        serial += salt.to_s
      end
      shard = Digest::MD5.hexdigest(serial).to_i(16) % chunks.to_i
      # we dont want to have a zero shard
      return shard + 1
    end

    def in_shard?(threshold)
      get_shard.to_i <= threshold.to_i
    end

    # This method allows you to conditionally shard chef resources
    # @param threshold [Fixnum] An integer value that you are sharding up to.
    # @yields The contents of the ruby block if the node is in the shard.
    # @example
    #  This will log 'hello' during the chef run for all nodes <= shard 5
    #   node.shard_block(5) do
    #     log 'hello' do
    #       level :info
    #     end
    #   end
    def shard_block(threshold, &block)
      yield block if block_given? && in_shard?(threshold) 
    end

    def warn_to_remove(stack_depth)
        stack = caller(stack_depth)[0]
        parts = %r{^.*/cookbooks/([^/]*)/([^/]*)/(.*)\.rb:(\d+)}.match(stack)
        if parts
          where = "(#{parts[1]}::#{parts[3]} line #{parts[4]})"
        else
          where = stack
        end
        Chef::Log.warn("Past time shard duration! Please cleanup! #{where}")
    end

    def in_timeshard?(start_time, duration)
      st = Time.parse(start_time).tv_sec
      return false unless st
      # Multiply the number of days by 1440 min and 60 s to convert a day into
      # seconds.
      if duration.match('^[0-9]+[dD]$')
        duration = duration.to_i * 1440 * 60
      # Multiply the number of hours by 3600 s to convert hours into seconds.
      elsif duration.match('^[0-9]+[hH]$')
        duration =  duration.to_i * 3600
      else
        errmsg = "Invalid duration arg, '#{duration}', to in_timeshard?()."
        fail errmsg
      end
      curtime = Time.now.tv_sec
      # The timeshard will be the number of seconds into the duration.
      time_shard = get_shard(chunks: duration)
      # The time threshold is the sum of the start time and time shard.
      time_threshold = st + time_shard
      # If the current time is greater than the threshold then the node will be
      # within the threshold of time as defined by the start time and duration,
      # and will return true.
      if curtime > st + duration
        warn_to_remove(3)
     end
      return curtime >= time_threshold
    end

     def shard_over_a_week_starting(start_date)
       in_shard?(rollout_shard(start_date))
     end

     def shard_over_a_week_ending(end_date)
       start_date = Date.parse(end_date) - 7
       in_shard?(rollout_shard(start_date.to_s))
     end

     def rollout_shard(start_date)
      rollout_map = [
        1,
        10,
        25,
        50,
        100
      ]
      rd = Date.parse(start_date)

      # Now we use today as an index into the rollout map, except we have to
      # discount weekends
      today = Date.today
      numdays = (today - rd).to_i
      num_weekend_days = 0
      (0..numdays).each do |i|
        t = rd + i
        if t.saturday? || t.sunday?
          num_weekend_days += 1
        end
      end

      # Subtract that from how far into the index we go
      numdays -= num_weekend_days

      if numdays < 0
        return 0
      end

      Chef::Log.debug("rollout_shard: days into rollout: #{numdays}")

      if numdays >= rollout_map.size
        warn_to_remove(3)
        shard = 100
      else
        shard = rollout_map[numdays]
      end
      Chef::Log.debug("rollout_shard: rollout_shard: #{shard}")
      shard
    end

    def os_greater_than?(version)
      case node['platform_family']
      when 'mac_os_x'
        Gem::Version.new(node['platform_version']) > Gem::Version.new(version)
      end
    end

    def os_less_than?(version)
      case node['platform_family']
      when 'mac_os_x'
        Gem::Version.new(node['platform_version']) < Gem::Version.new(version)
      end
    end

    def os_at_least?(version)
      case node['platform_family']
      when 'mac_os_x'
        Gem::Version.new(node['platform_version']) >= Gem::Version.new(version)
      end
    end

    def os_at_least_or_lower?(version)
      case node['platform_family']
      when 'mac_os_x'
        Gem::Version.new(node['platform_version']) <= Gem::Version.new(version)
      end
    end

    def linux?
      return node['os'] == 'linux'
    end

    def ubuntu?
      return node['platform'] == 'ubuntu'
    end

    def centos?
      return node['platform'] == 'centos'
    end

    def macos?
      return node['platform'] == 'mac_os_x'
    end

    def macosx?
      self.macos?
    end

    def windows?
      return node['os'] == 'windows'
    end

    # Does not work on OS X as it does not have this ohai plugin by default
    def virtual?
      if node['virtualization2']
        return node['virtualization2'] &&
          node['virtualization2']['role'] == 'guest'
      else
        return node['virtualization'] &&
          node['virtualization']['role'] == 'guest'
      end
    end

    def munki_installed?(application)
      installed_apps = []
      if File.exist?('/Library/Managed Installs/ManagedInstallReport.plist')
        # Parse plist and lowercase all values
        begin
          installed_apps  = Plist.parse_xml(
            '/Library/Managed Installs/ManagedInstallReport.plist'
          )['managed_installs_list'].map(&:downcase)
        rescue
          Chef::Log.warn(
            'custom_utils/node.munki_installed:' +
            ' Failed to retrieve applications installed by Munki'
          )
        end
      end
      # Update ohai attribute
      node.override['munki']['installed_apps'] = installed_apps
      # Return true or false if applicaion is installed by munki
      installed_apps.include?(application)
    end
  end
end
