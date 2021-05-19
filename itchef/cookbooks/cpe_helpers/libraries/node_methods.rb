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
#

require_relative '../../fb_helpers/libraries/node_methods'

class Chef
  # Our extensions of the node object
  class Node
    def check_port_connectivity(host, port, timeout = 2)
      CPE::Helpers.check_port_connectivity(host, port, timeout)
    end

    def chef_greater_than?(version)
      Chef::Version.new(Chef::VERSION) > Chef::Version.new(version)
    end

    def chef_is?(version)
      Chef::Version.new(Chef::VERSION) == Chef::Version.new(version)
    end

    def chef_less_than?(version)
      Chef::Version.new(Chef::VERSION) < Chef::Version.new(version)
    end

    def dmi_ram_total
      CPE::Helpers.dmi_ram_total(node)
    end

    def os_at_least?(version)
      if arch? || debian_sid?
        # Arch and debian/sid is a rolling release so it's always at a
        # sufficient version
        return true
      end
      Gem::Version.new(node['platform_version']) >= Gem::Version.new(version)
    end

    def os_at_most?(version)
      if arch? || debian_sid?
        # Arch and debian/sid is a rolling release so it's always at a
        # sufficient version
        return true
      end
      Gem::Version.new(node['platform_version']) <= Gem::Version.new(version)
    end

    def os_greater_than?(version)
      if arch? || debian_sid?
        # Arch and debian_sid is a rolling release so it's always at a
        # sufficient version
        return true
      end
      Gem::Version.new(node['platform_version']) > Gem::Version.new(version)
    end

    def os_less_than?(version)
      if arch? || debian_sid?
        # Arch and debian/sid is a rolling release so it's always "latest"
        return false
      end
      Gem::Version.new(node['platform_version']) < Gem::Version.new(version)
    end

    def console_user
      CPE::Helpers.console_user
    end

    def console_user_home_dir
      CPE::Helpers.console_user_home_dir
    end

    def loginwindow?
      CPE::Helpers.loginwindow?
    end

    def win_choco_pkg_installed?(package_name)
      unless windows?
        Chef::Log.warn('node.win_choco_pkg_installed? called on non-Windows!')
        return false
      end
      # bundle_identifiers are case sensitive
      query = <<-SQL
        SELECT name
        FROM chocolatey_packages
        WHERE
          LOWER(name) == LOWER('#{package_name}')
      SQL
      osquery_data = Osquery.query(query, 'windows')
      !osquery_data.empty?
    rescue StandardError
      Chef::Log.warn("Unable to query Choco package #{package_name}")
      nil
    end

    def mac_bundleid_installed?(bundle_identifier)
      unless macos?
        Chef::Log.warn('node.mac_bundleid_installed? called on non-macOS!')
        return false
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
          LOWER(name) LIKE LOWER('#{app_name}')
      SQL
      osquery_data = Osquery.query(query, platform)
      matches = osquery_data.map(&:values).flatten
      Chef::Log.debug("Fuzzy matches: #{matches}")
      !osquery_data.empty?
    rescue StandardError
      Chef::Log.warn("Unable to query app #{app_name}")
      nil
    end

    def installed?(name_or_identifier)
      installed = false
      case node['os']
      when 'darwin'
        # bundle identifiers almost certainly have '.' in the name,
        # so try that first
        if name_or_identifier.include?('.')
          installed = mac_bundleid_installed?(name_or_identifier)
        end
      end
      installed || app_installed?(name_or_identifier)
    rescue StandardError
      Chef::Log.warn("Unable to determine installation for:
                     #{name_or_identifier}")
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
        return linux_app_paths(app_name)
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

    def linux_app_paths(pkg_name)
      case node['platform']
      when 'fedora'
        cmd = "rpm -ql #{pkg_name}"
      when 'ubuntu', 'debian'
        cmd = "dpkg -L #{pkg_name}"
      when 'arch'
        cmd = "pacman -Qlq #{pkg_name}"
      else
        Chef::Log.warn(
          "Querying app paths not supported on #{node['platform']}",
        )
        return []
      end
      res = shell_out(cmd)

      if res.error?
        Chef::Log.error("Failed to run #{cmd}")
        return []
      end

      res.stdout.lines.map(&:strip)
    end

    def rpm_cmpver(verstr1, verstr2, compare_epoch = false)
      CPE::Helpers.rpm_cmpver(verstr1, verstr2, compare_epoch)
    end

    def rpm_installed?(name, verstr = nil,
                       compare_epoch = false, exact = true)
      CPE::Helpers.rpm_installed?(name, verstr, compare_epoch, exact)
    end

    def rpm_parsever(verstr)
      CPE::Helpers.rpm_parsever(verstr)
    end

    def rpm_parserel(relstr)
      CPE::Helpers.rpm_parserel(relstr)
    end
  end
end
