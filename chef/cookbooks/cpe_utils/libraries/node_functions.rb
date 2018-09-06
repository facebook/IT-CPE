# Cookbook Name:: cpe_utils
# Library::node_functions
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
    #  irb> node.attr_lookup('awesome/not_there')
    #  => nil
    #  irb> node.attr_lookup('awesome')
    #  => "yup"
    #  irb> node.override.not_cool = 'but still functional'
    #  => "but still functional"
    #  irb> node.attr_lookup('not_cool')
    #  => "but still functional"
    #  irb> node.attr_lookup('default_val', default: 'I get this back anyway')
    #  => "I get this back anyway"
    #  irb> node.automatic.a.very.deeply.nested.value = ':)'
    #  => ":)"
    #  irb> node.attr_lookup('a/very/deeply/nested/value')
    #  => ":)"
    def attr_lookup(path, delim: '/', default: nil)
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
      unless macos?
        Chef::Log.warn('node.console_user called on non-OS X!')
        return
      end
      usercmd = Mixlib::ShellOut.new(
        '/usr/bin/stat -f%Su /dev/console',
      ).run_command.stdout
      username = usercmd.chomp
      username
    end

    def serial
      unless macos?
        Chef::Log.warn('node.serial called on non-OS X!')
        return
      end
      return node['serial'] if node['serial']
      serial = Mixlib::ShellOut.new(
        '/usr/sbin/ioreg -c IOPlatformExpertDevice |head -30' +
        '|grep IOPlatformSerialNumber | awk \'{print $4}\' | sed -e s/\"//g',
      ).run_command.stdout.chomp
      node.default['serial'] = serial
      serial
    end

    def uuid
      unless macos?
        Chef::Log.warn('node.serial called on non-OS X!')
        return
      end
      return node['uuid'] if node['uuid']
      uuid = Mixlib::ShellOut.new(
        '/usr/sbin/system_profiler SPHardwareDataType' +
        '| awk \'/UUID/ { print $3; }\'',
      ).run_command.stdout.chomp
      node.default['uuid'] = uuid
      uuid
    end

    def get_shard(serial: nil, salt: nil, chunks: 100)
      if serial.nil?
        # grab the serial by platform if possible
        # return nil if not possible
        case node['os']
        when 'darwin', 'linux'
          serial ||= node.serial
          if serial.nil?
            serial = attr_lookup('cpe/hardware/system_uuid')
          end
        when 'windows'
          # On windows prefer uuid first
          serial = attr_lookup('cpe/hardware/system_uuid')
        end
      end
      if serial.nil?
        # use the last possible shard so that when we slowroll
        # we don't hit these hosts until the end
        99
      end
      if salt
        serial += salt.to_s
      end
      shard = Digest::MD5.hexdigest(serial).to_i(16) % chunks.to_i
      # we dont want to have a zero shard
      shard + 1
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
      passed_duration = duration
      st = Time.parse(start_time).tv_sec
      return false unless st
      # Multiply the number of days by 1440 min and 60 s to convert a day into
      # seconds.
      if duration.match('^[0-9]+[dD]$')
        duration = duration.to_i * 1440 * 60
      # Multiply the number of hours by 3600 s to convert hours into seconds.
      elsif duration.match('^[0-9]+[hH]$')
        duration = duration.to_i * 3600
      else
        errmsg = "Invalid duration arg, '#{duration}', to in_timeshard?()."
        fail errmsg
      end
      curtime = Time.now.tv_sec
      # The timeshard will be the number of seconds into the duration.
      time_shard = get_shard(:chunks => duration)
      # The time threshold is the sum of the start time and time shard.
      time_threshold = st + time_shard
      Chef::Log.debug("time_shard: #{time_shard}, #{Time.at(time_threshold)}")
      node.default['timeshard']["#{start_time}_#{passed_duration}"] = {
        'time' => Time.at(time_threshold),
      }
      # If the current time is greater than the threshold then the node will be
      # within the threshold of time as defined by the start time and duration,
      # and will return true.
      if curtime > st + duration
        warn_to_remove(3)
      end
      curtime >= time_threshold
    end

    def shard_over_a_week_starting(start_date)
      in_shard?(rollout_shard(start_date))
    end

    def shard_over_a_week_ending(end_date)
      start_date = Date.parse(end_date) - 7
      in_shard?(rollout_shard(start_date.to_s))
    end

    def shard_per_hour(percent, start_time)
      hours = "#{100 / percent}H"
      Chef::Log.debug(
        "shard_per_hour:time: #{hours}, start_time: #{start_time}",
      )
      in_timeshard?(start_time, hours)
    end

    def shard_per_day(percent, start_date)
      days = "#{(100 / percent)}D"
      Chef::Log.debug(
        "shard_per_day:time: #{days}, s art_date: #{start_date}",
      )
      in_timeshard?("#{start_date} 9:00", days)
    end

    def rollout_shard(start_date)
      rollout_map = [
        1,
        10,
        25,
        50,
        100,
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
        0
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
      if arch?
        # Arch is a rolling release so it's always at a sufficient version
        true
      end
      Gem::Version.new(node['platform_version']) >= Gem::Version.new(version)
    end

    def os_at_least_or_lower?(version)
      case node['platform_family']
      when 'mac_os_x'
        Gem::Version.new(node['platform_version']) <= Gem::Version.new(version)
      end
    end

    def arch?
      node['platform'] == 'arch'
    end

    def linux?
      node['os'] == 'linux'
    end

    def ubuntu?
      node['platform'] == 'ubuntu'
    end

    def debian?
      node['platform'] == 'debian'
    end

    def centos?
      node['platform'] == 'centos'
    end

    def fedora?
      node['platform'] == 'fedora'
    end

    def linuxmint?
      node['platform'] == 'linuxmint'
    end

    def debian_family?
      node['platform_family'] == 'debian'
    end

    def arch_family?
      node['platform_family'] == 'arch'
    end

    def fedora_family?
      node['platform_family'] == 'fedora'
    end

    def macosx?
      self.macos?
    end

    def macos?
      node['platform'] == 'mac_os_x'
    end

    def windows?
      node['os'] == 'windows'
    end

    def windows8?
      self.windows? && node['platform_version'].start_with?('6.2')
    end

    def windows8_1?
      self.windows? && node['platform_version'].start_with?('6.3')
    end

    def windows10?
      self.windows? && node['platform_version'].start_with?('10.0')
    end

    def windows2012?
      self.windows? && node['platform_version'].start_with?('6.2')
    end

    def windows2012r2?
      self.windows? && node['platform_version'].start_with?('6.3')
    end

    def ubuntu14?
      self.ubuntu? && node['platform_version'].start_with?('14.')
    end

    def ubuntu15?
      self.ubuntu? && node['platform_version'].start_with?('15.')
    end

    def ubuntu16?
      self.ubuntu? && node['platform_version'].start_with?('16.')
    end

    def fedora27?
      self.fedora? && node['platform_version'].eql?('27')
    end

    def fedora28?
      self.fedora? && node['platform_version'].eql?('28')
    end

    def debian_sid?
      self.debian? && node['platform_version'].include?('sid')
    end

    def parallels?
      virtual_macos_type == 'parallels'
    end

    def vmware?
      virtual_macos_type == 'vmware'
    end

    def virtualbox?
      virtual_macos_type == 'virtualbox'
    end

    def sysnative_path
      if RUBY_PLATFORM.include? '64'
        "#{ENV['WINDIR']}\\system32\\"
      else
        "#{ENV['WINDIR']}\\sysnative\\"
      end
    end

    def supports_dsc?
      if node['languages'].attribute?('powershell')
        node['languages']['powershell']['version'].to_i >= 5
      end
      false
    end

    def windows_supports_long_paths?
      case node['os']
      when 'darwin'
        # let's be pedantic in relation to the function name
        false
      when 'windows'
        res = node['platform_version'].delete('.').to_i >= 10014393
        unless res
          Chef::Log.warn(
            'Windows build is too old to support long paths. ' +
            'Update to at least 10.0.14393.',
          )
        end
        res
      end
      Chef::Log.warn(
        "The platform #{node['os']} is unknown. " +
        'Please contact CPE if you see this message',
      )
      false
    end


    # returns either nil, "mdm", "uamdm", or "dep"
    def _parse_profiles_status(output)
      if output.include?('Enrolled via DEP: Yes')
        'dep'
      elsif output.include?('An enrollment profile is currently installed ' +
          'on this system') # macOS 10.13.1 response
        'dep'
      elsif output.include?('MDM enrollment: Yes (User Approved)')
        'uamdm'
      elsif output.include?('MDM enrollment: Yes')
        'mdm'
      end
    end

    # returns nil or "mdm"
    def _parse_profiles_profiles(output)
      profiles = Plist.parse_xml(output)
      fail 'profiles XML parsing cannot be nil!' if profiles.nil?
      fail 'profiles XML parsing must be a Hash!' unless profiles.is_a?(Hash)
      if profiles.key?('_computerlevel')
        profiles['_computerlevel'].each do |profile|
          profile['ProfileItems'].each do |item|
            'mdm' if item['PayloadType'] == 'com.apple.mdm'
          end
        end
      end
      nil
    end

    def macos_mdm_state
      unless macos?
        Chef::Log.warn('node.macos_mdm_state called on non-macOS!')
        nil
      end
      status = nil
      if os_at_least?('10.13.0')
        status = _parse_profiles_status(shell_out(
          '/usr/bin/profiles status -type enrollment',
        ).stdout.to_s)
      end
      # on 10.13.3 or ealier we can detect DEP but cannot detect non-DEP MDM
      # in those cases fall back to looking at profiles
      if os_at_least_or_lower?('10.13.3') && status != 'dep'
        status = _parse_profiles_profiles(shell_out(
          '/usr/bin/profiles -Lo stdout-xml',
        ).stdout.to_s)
      end
      status
    end

    def mdm?
      macos_mdm_state == 'mdm'
    end

    def uamdm?
      macos_mdm_state == 'uamdm'
    end

    def dep?
      macos_mdm_state == 'dep'
    end

    def virtual?
      if macos?
        virtual_macos_type != 'physical'
      end
      if node['virtualization2']
        node['virtualization2'] &&
          node['virtualization2']['role'] == 'guest'
      else
        node['virtualization'] &&
          node['virtualization']['role'] == 'guest'
      end
    end

    # Granular virtual device type for macOS
    def virtual_macos_type
      unless macos?
        Chef::Log.warn('node.virtual_macos called on non-macOS!')
        return
      end
      node['virtual_macos'] if node['virtual_macos']
      if node['hardware']['boot_rom_version'].include? 'VMW'
        virtual_type = 'vmware'
      elsif node['hardware']['boot_rom_version'].include? 'VirtualBox'
        virtual_type = 'virtualbox'
      else
        virtual_type = shell_out(
          '/usr/sbin/system_profiler SPEthernetDataType',
        ).run_command.stdout.to_s[/Vendor ID: (.*)/, 1]
        if virtual_type && virtual_type.include?('0x1ab8')
          virtual_type = 'parallels'
        else
          virtual_type = 'physical'
        end
      end
      virtual_type
    end

    def munki_installed?(application)
      installed_apps = []
      if File.exist?('/Library/Managed Installs/ManagedInstallReport.plist')
        # Parse plist and lowercase all values
        begin
          installed_apps = Plist.parse_xml(
            '/Library/Managed Installs/ManagedInstallReport.plist',
          )['managed_installs_list'].map(&:downcase)
        rescue StandardError
          Chef::Log.warn(
            'cpe_utils/node.munki_installed:' +
            ' Failed to retrieve applications installed by Munki',
          )
        end
      end
      # Update ohai attribute
      node.override['munki']['installed_apps'] = installed_apps
      # Return true or false if applicaion is installed by munki
      installed_apps.include?(application)
    end

    def loginwindow?
      if windows?
        Chef::Log.warn('node.loginwindow? called on Windows!')
        return
      end
      if macos?
        console_user == 'root'
      elsif linux?
        attr_lookup("sessions/by_user/#{console_user}").nil?
      end
    end

    def mac_bundleid_installed?(bundle_identifier)
      unless macos?
        Chef::Log.warn('node.mac_bundleid_installed? called on non-macOS!')
        false
      end
      # bundle_identifiers are case sensitive
      query = <<-SQL
        SELECT name
        FROM apps
        WHERE
          LOWER(bundle_identifier) == LOWER('#{bundle_identifier}')
      SQL
      osquery_data = Osquery.query(query)
      !osquery_data.empty?
    rescue StandardError
      Chef::Log.warn("Unable to query bundle identifier #{bundle_identifier}")
      nil
    end

    def app_paths(app_name)
      case node['os']
      when 'darwin'
        table_name = 'apps'
        platform = 'posix'
      when 'windows'
        table_name = 'programs'
        platform = 'windows'
      when 'linux'
        table_name = value_for_platform_family(
          'debian' => 'deb_packages',
          # Eventually, more Linux distros can go here
        )
        platform = 'posix'
      end
      query = <<-SQL
        SELECT path
        FROM #{table_name}
        WHERE
          LOWER(name) LIKE LOWER('%#{app_name}%')
      SQL
      osquery_data = Osquery.query(query, platform)
      matches = osquery_data.map(&:values).flatten
      Chef::Log.debug("Fuzzy matches: #{matches}")
      matches
    rescue StandardError
      Chef::Log.warn("Unable to query app paths #{app_name}")
      []
    end

    def app_paths_deprecated(bundle_identifier)
      unless macos?
        Chef::Log.warn('node.app_paths_deprecated called on non-OS X!')
        []
      end
      # Search Spotlight for matching identifier, strip newlines
      Mixlib::ShellOut.new(
        "/usr/bin/mdfind \"kMDItemCFBundleIdentifier==#{bundle_identifier}\"",
      ).run_command.stdout.split('\n').map!(&:chomp)
    end

    def installed?(bundle_identifier)
      unless macos?
        Chef::Log.warn('node.installed? called on non-OS X!')
        false
      end
      paths = app_paths_deprecated(bundle_identifier)
      !paths.empty?
    end

    def app_installed?(app_name)
      case node['os']
      when 'darwin'
        table_name = 'apps'
        platform = 'posix'
      when 'windows'
        table_name = 'programs'
        platform = 'windows'
      when 'linux'
        table_name = value_for_platform_family(
          'debian' => 'deb_packages',
          'fedora' => 'rpm_packages',
          # Eventually, more Linux distros can go here
        )
        platform = 'posix'
      end
      query = <<-SQL
        SELECT name
        FROM #{table_name}
        WHERE
          LOWER(name) LIKE LOWER('%#{app_name}%')
      SQL
      osquery_data = Osquery.query(query, platform)
      matches = osquery_data.map(&:values).flatten
      Chef::Log.debug("Fuzzy matches: #{matches}")
      !osquery_data.empty?
    rescue StandardError
      Chef::Log.warn("Unable to query app #{app_name}")
      nil
    end

    def min_package_installed?(pkg_identifier, min_pkg)
      unless macos?
        Chef::Log.warn('node.min_package_installed? called on non-OS X!')
        false
      end
      installed_pkg_version = shell_out(
        "/usr/sbin/pkgutil --pkg-info \"#{pkg_identifier}\"",
      ).run_command.stdout.to_s[/version: (.*)/, 1]
      # Compare the installed version to the minimum version
      if installed_pkg_version.nil?
        Chef::Log.warn("Package #{pkg_identifier} returned nil.")
        false
      end
      Gem::Version.new(installed_pkg_version) >= Gem::Version.new(min_pkg)
    end

    def max_package_installed?(pkg_identifier, max_pkg)
      unless macos?
        Chef::Log.warn('node.max_package_installed? called on non-OS X!')
        false
      end
      installed_pkg_version = shell_out(
        "/usr/sbin/pkgutil --pkg-info \"#{pkg_identifier}\"",
      ).run_command.stdout.to_s[/version: (.*)/, 1]
      # Compare the installed version to the maximum version
      if installed_pkg_version.nil?
        Chef::Log.warn("Package #{pkg_identifier} returned nil.")
        false
      end
      Gem::Version.new(installed_pkg_version) <= Gem::Version.new(max_pkg)
    end
  end
end
