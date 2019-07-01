# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_choco
# Resource:: cpe_choco_bootstrap
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_choco_bootstrap
default_action :install

property :version, :kind_of => String

load_current_value do
  ver = Mixlib::ShellOut.new('C:\ProgramData\chocolatey\choco.exe --version')
  begin
    choco_version = ver.run_command.stdout.chomp
    fail if choco_version.empty?
  rescue
    Chef::Log.warn('Chocolatey executable was not found!')
    choco_version = '0.0.0'
  end
  set_or_return(:version, choco_version, {})
end

action :install do
  unless node['platform_family'] == 'windows'
    Chef::Log.warn("Chocolatey is not supported on #{node['platform_family']}.")
    return
  end

  bootstrap_choco
  @new_resource.version = node['cpe_choco']['bootstrap']['version']
  converge_if_changed :version do
    upgrade_to_version(node['cpe_choco']['bootstrap']['version'])
  end
end

action_class do
  def upgrade_to_version(new_version)
    choco_exe = 'C:\ProgramData\chocolatey\choco.exe'
    upgrade_source = node['cpe_choco']['bootstrap']['upgrade_source']
    pkg = 'chocolatey'
    # rubocop:disable Metric/LineLength
    powershell_script 'upgrade_choco' do
      code <<-EOF
& #{choco_exe} upgrade --allow-downgrade --version=#{new_version} -y -s #{upgrade_source} #{pkg}
EOF
      action :run
    end
    # rubocop:enable Metric/LineLength
  end

  def bootstrap_choco
    script_path =
      ::File.join(Chef::Config[:file_cache_path], 'choco_bootstrap.ps1')
    cookbook_file 'chocolatey bootstrap file' do
      path script_path
      source 'bootstrap.ps1'
      rights :read, 'Users'
      rights :full_control, 'Administrators'
    end

    powershell_script 'chocolatey_install' do
      not_if do
        ::File.file?('C:\ProgramData\chocolatey\choco.exe') &&
        ENV.key?('ChocolateyInstall')
      end
      environment(
        {
          'chocolateyDownloadUrl' =>
            node['cpe_choco']['bootstrap']['choco_download_url'],
          'chocolateyZipLocation' =>
            node['cpe_choco']['bootstrap']['zip_location'],
          'chocolateyUseWindowsCompression' =>
            node['cpe_choco']['bootstrap']['use_windows_compression'],
          'chocolateyVersion' => node['cpe_choco']['bootstrap']['version'],
        },
      )
      code "& #{script_path}"
      action :run
    end
  end
end
