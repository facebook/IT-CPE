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
      CPE::Helpers.dmi_ram_total(self)
    end

    def os_at_least?(version)
      if arch? || debian_sid?
        # Arch and debian/sid is a rolling release so it's always at a
        # sufficient version
        return true
      end
      Gem::Version.new(self['platform_version']) >= Gem::Version.new(version)
    end

    def os_at_most?(version)
      if arch? || debian_sid?
        # Arch and debian/sid is a rolling release so it's always at a
        # sufficient version
        return true
      end
      Gem::Version.new(self['platform_version']) <= Gem::Version.new(version)
    end

    def os_greater_than?(version)
      if arch? || debian_sid?
        # Arch and debian_sid is a rolling release so it's always at a
        # sufficient version
        return true
      end
      Gem::Version.new(self['platform_version']) > Gem::Version.new(version)
    end

    def os_less_than?(version)
      if arch? || debian_sid?
        # Arch and debian/sid is a rolling release so it's always "latest"
        return false
      end
      Gem::Version.new(self['platform_version']) < Gem::Version.new(version)
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
