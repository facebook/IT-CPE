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

module CPE
  class Helpers
    def self.loginctl_users
      @loginctl_users ||= begin
        # Standard path in Fedora
        loginctl_path = '/usr/bin/loginctl'
        if linux? && ::File.exist?(loginctl_path)
          res = shell_out("#{loginctl_path} list-users")
          return [] if res.error?

          # first line is header
          # last two lines are empty line and user count
          user_lines = res.stdout.lines[1..-3]
          user_lines.map do |u|
            uid, uname = u.split
            { 'uid' => Integer(uid), 'username' => uname }
          end
        else []
        end
      end
    end

    def self.loginwindow?
      if macos?
        ['root', '_mbsetupuser'].include?(console_user)
      elsif linux?
        loginctl_users.any? do |u|
          u['username'] == 'gdm'
        end && loginctl_users.none? do |u|
          u['uid'] >= 1000
        end
      else
        false
      end
    end

    def self.console_user
      # memoize the value so it isn't executed multiple times per run
      @console_user ||=
        if macos?
          Etc.getpwuid(::File.stat('/dev/console').uid).name
        elsif linux?
          filtered_users = loginctl_users.select do |u|
            u['username'] != 'gdm' && u['uid'] >= 1000
          end
          if filtered_users.empty? && ::File.exist?('/etc/fb-machine-owner')
            # TODO T54156500: Evaluate whether this is still necessary
            CPE::Log.log(
              'Reading fb-machine-owner',
              :type => 'cpe::helpers.console_user',
              :action => 'read_from_fb-machine-owner',
            )
            IO.read('/etc/fb-machine-owner').chomp
          else
            filtered_users[0]['username']
          end
        end
    rescue StandardError => e
      Chef::Log.warn("Unable to determine user: #{e}")
      nil
    end

    def self.console_user_home_dir
      if macos?
        return nil if loginwindow?
        standard_home = ::File.join("/Users/#{console_user}")
        return standard_home if ::Dir.exist?(standard_home)
        plist_results = shell_out(
          "/usr/bin/dscl -plist . read /Users/#{console_user} " +
          'NFSHomeDirectory',
        ).stdout
        plist_data = Plist.parse_xml(plist_results)
        homes = plist_data.to_h.fetch('dsAttrTypeStandard:NFSHomeDirectory', [])
        return homes[0]
      end
      if linux?
        standard_home = ::File.join("/home/#{console_user}")
        return standard_home if ::Dir.exist?(standard_home)
      end
      if windows?
        standard_home = ::File.join(ENV['SYSTEMDRIVE'], 'Users', console_user)
        return standard_home if ::Dir.exist?(standard_home)
      end
    rescue StandardError
      Chef::Log.warn('Unable to lookup console_user_home_dir ' +
        "#{e.message} \n" +
        "#{e.backtrace.to_a.join("\n")}\n")
      nil
    end

    def self.macos?
      RUBY_PLATFORM.include?('darwin')
    end

    def self.linux?
      RUBY_PLATFORM.include?('linux')
    end

    def self.windows?
      RUBY_PLATFORM =~ /mswin|mingw32|windows/
    end
  end
end
