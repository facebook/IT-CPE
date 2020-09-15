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
    LOGON_REG_KEY =
      'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'.freeze

    # Method to check for port open on a host.
    def self.check_port_connectivity(host, port, timeout = 2)
      if self.valid_uri?(host)
        uri = URI.parse(host)
        host = uri.host
        port = uri.port
      end

      Socket.tcp(host, port, :connect_timeout => timeout).close
      true
    rescue StandardError
      Chef::Log.debug(
        'CPE::Helpers.check_port_connectivity: ' +
        "#{host} not reachable on #{port}",
      )
      false
    end

    def self.dmi_ram_total(node)
      # for Linux
      # try to get the data from DMI first, and fallback to node['memory']
      # which gets it from meminfo
      mem_devs = node['dmi'].to_h.dig('memory_device', 'all_records') || []

      # 'Size' is a string e.g. '32 GB'. convert to int, add up all the sizes
      # for all filled RAM slots then convert to KBs
      total = mem_devs.map { |rec| self.parse_ram(rec['Size']) }.reduce(:+)

      if total.nil? || total.zero?
        node['memory'].to_h.dig('total').to_i
      else
        total
      end
    end

    def self.loginctl_users
      @loginctl_users ||= begin
        # Standard path in Fedora
        loginctl_path = nil
        [
          # Fedora and most distros
          '/usr/bin/loginctl',
          # Ubuntu, and probably Debian too
          '/bin/loginctl',
        ].each do |p|
          if ::File.exist?(p)
            loginctl_path = p
            break
          end
        end

        if linux? && !loginctl_path.nil?
          # don't use loginctl -o json as that's only supported in very recent
          # systemd (e.g. not in vanilla CentOS 8 and Ubuntu 18.04)
          res = shell_out("#{loginctl_path} --no-legend list-users")
          return [] if res.error?

          res.stdout.lines.map do |u|
            uid, uname = u.split
            { 'uid' => Integer(uid), 'user' => uname }
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
          u['user'] == 'gdm'
        end && loginctl_users.none? do |u|
          u['uid'] > sys_uid_max
        end
      else
        false
      end
    end

    def self.admin_groups
      @admin_groups ||=
        if linux?
          @os_release ||= begin
            entries = ::File.readlines('/etc/os-release').map do |line|
              line.chomp.split('=')
            end
            # handle the case where os-release contains blank lines
            # looking at you, CentOS 8
            entries.select { |ent| ent.length == 2 }.to_h
          end
          # again, CentOS' os-release unnecessarily quotes single words
          case @os_release['ID'].gsub(/\"|\'/, '')
          when 'fedora', 'centos', 'arch'
            ['wheel']
          when 'debian'
            ['sudo']
          when 'ubuntu'
            ['admin', 'sudo']
          else
            []
          end
        elsif macos?
          ['admin']
        else
          []
        end
    end

    def self.admin_users
      @admin_users ||=
        admin_groups.flat_map do |g|
          begin
            ::Etc.getgrnam(g).mem
          rescue StandardError
            []
          end
        end
    end

    def self.console_user
      # memoize the value so it isn't executed multiple times per run
      @console_user ||=
        if macos?
          ::Etc.getpwuid(::File.stat('/dev/console').uid).name
        elsif linux?
          filtered_users = loginctl_users.select do |u|
            u['user'] != 'gdm' && u['uid'] >= 1000
          end
          if filtered_users.empty?
            # TODO T54156500: Evaluate whether this is still necessary
            CPE::Log.log(
              'No console user detected, falling back to machine owner',
              :type => 'cpe::helpers.console_user',
              :action => 'read_from_machine_owner',
            )
            machine_owner
          else
            filtered_users[0]['user']
          end
        elsif windows?
          logged_on_user_name
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

    def self.logged_on_user_query
      query = shell_out('%WINDIR%\system32\query.exe user', :timeout => 60)
      output = query.stdout.split("\n")

      if output.size <= 1
        Chef::Log.debug('no one is currently logged in')
        return nil
      end

      # Drop the header row. Naively return the first active session.
      output.drop(1).each do |line|
        row = line.split
        # The > usually indicates the user that ran the command, which in most
        # cases is you! Regardless, it should be dropped from what is returned
        # to chef.
        return row[0].tr('>', '').strip if row[3].strip.downcase == 'active'
      end
    rescue Mixlib::ShellOut::CommandTimeout
      Chef::Log.warn('command timeout while looking up user')
    rescue StandardError => e
      Chef::Log.warn(e.to_s)

      nil
    end

    def self.logged_on_user_registry
      u = Win32::Registry::HKEY_LOCAL_MACHINE.open(
        LOGON_REG_KEY, Win32::Registry::KEY_READ
      ) do |reg|
        reg.to_a.each_with_object({}).each { |(a, _, c), obj| obj[a] = c }
      end
      u.select! { |k, _| k =~ /user/i }
    end

    def self.logged_on_user_name
      logged_on_user_query
    end

    def self.logged_on_user_sid
      logged_on_user_registry['LastLoggedOnUserSID']
    end

    def self.ldap_lookup_script(username)
      script = <<-'EOF'
$desiredProperties = @(
  ## We only need UPN and memberof
  'memberof'
  'userprincipalname'
)
$ADSISearcher = New-Object System.DirectoryServices.DirectorySearcher
$ADSISearcher.Filter = '(&(sAMAccountName=%s)(objectClass=user))'
$ADSISearcher.SearchScope = 'Subtree'
$desiredProperties |
  ForEach-Object {
    $ADSISearcher.PropertiesToLoad.Add($_) |
    Out-Null
  }
$ADSISearcher.FindAll() |
  Select-Object -Expand Properties |
  ConvertTo-Json -Compress
EOF
      @ldap_lookup_script ||= format(script, username)
    end

    def self.ldap_user_info(username: logged_on_user_name)
      data = {}
      script = ldap_lookup_script(username)
      raw_data = powershell_out!(script).stdout
      begin
        encoded_data = raw_data.encode(Encoding::UTF_8)
      rescue Encoding::UndefinedConversionError
        # The culprit is CP850! https://stackoverflow.com/a/50467853/487509
        raw_data.force_encoding(Encoding::CP850)
        encoded_data = raw_data.encode(Encoding::UTF_8)
      end
      data = JSON.parse(encoded_data)
    rescue StandardError => e
      Chef::Log.warn("could not lookup ldap user info for #{username}: #{e}")
      data
    end

    def self.machine_owner
      @machine_owner ||=
        if linux? || macos?
          admin_account_entries = admin_users.map do |u|
            ::Etc.getpwnam(u)
          end
          user_account_entries = admin_account_entries.select do |ent|
            ent.uid > sys_uid_max && !%w{admin ubuntu fedora}.include?(ent.name)
          end
          if user_account_entries.empty?
            nil
          else
            user_account_entries.min_by(&:uid)['name']
          end
        end
    end

    def self.parse_ram(ramstr)
      if ramstr.upcase.end_with?('GB') # newer dmidecode e.g. on Fedora >= 32
        ramstr.to_i * 1024 * 1024
      elsif ramstr.upcase.end_with?('MB') # older dmidecode
        ramstr.to_i * 1024
      elsif ramstr.upcase.end_with?('KB') # for completeness
        ramstr.to_i
      else
        return 0 # give up, don't use this data
      end
    end

    def self.rpm_cmpver(verstr1, verstr2, compare_epoch = false)
      e1, v1, r1 = rpm_parsever(verstr1)
      e2, v2, r2 = rpm_parsever(verstr2)
      if compare_epoch
        if e1 > e2
          return 1
        elsif e1 < e2
          return -1
        end
      end
      if v1 > v2
        1
      elsif v1 < v2
        -1
      else
        parsed_rel1 = rpm_parserel(r1)
        parsed_rel2 = rpm_parserel(r2)
        if parsed_rel1[0] > parsed_rel2[0]
          1
        elsif parsed_rel1[0] < parsed_rel2[0]
          -1
        elsif parsed_rel1[1] > parsed_rel2[1]
          1
        elsif parsed_rel1[1] < parsed_rel2[1]
          -1
        else
          0
        end
      end
    end

    def self.rpm_installed?(name, verstr = nil,
                            compare_epoch = false, exact = true)
      pkg_to_check =
        if verstr.nil? || !exact
          name
        else
          "#{name}-#{verstr}"
        end

      rpm_q = shell_out(
        "rpm -q --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}' #{pkg_to_check}",
      )
      if rpm_q.error?
        false
      elsif verstr.nil?
        true
      else
        cmp = rpm_cmpver(rpm_q.stdout, verstr, compare_epoch)
        if exact
          cmp.zero?
        else
          cmp >= 0
        end
      end
    end

    def self.rpm_parsever(verstr)
      epoch_verrel = verstr.split(':')
      if epoch_verrel.count == 1
        epoch = 0
        verrel = verstr
      else
        estr, verrel = epoch_verrel
        if estr == '(none)' # rpm -q returns this if epoch is unset
          epoch = 0
        else
          epoch = estr.to_i
        end
      end
      ver_rel = verrel.split('-')
      if ver_rel.count == 1
        ver = verrel
        rel = '0'
      else
        ver, rel = ver_rel
      end
      begin
        gem_ver = Gem::Version.new(ver)
      rescue ArgumentError
        # some RPMs might have really weird version strings,
        # just leave them as strings and do string comparison
        gem_ver = ver
      end
      return [epoch, gem_ver, rel]
    end

    def self.rpm_parserel(relstr)
      rel_splits = relstr.split('.')
      [rel_splits[0].to_i, rel_splits[1..-1].join('.')]
    end

    def self.sys_uid_max
      @sys_uid_max ||=
        if macos?
          499
        elsif linux?
          999
        end
    end

    def self.valid_uri?(string)
      uri = URI.parse(string)
      %w{http https}.include?(uri.scheme)
    rescue StandardError
      false
    end
  end
end
