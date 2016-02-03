class Chef
  # Custom Extensions of the node object.
  class Node

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

    def macosx?
      return node['platform'] == 'mac_os_x'
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
            'cpe_utils/node.munki_installed:' +
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
