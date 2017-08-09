# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Cookbook Name:: cpe_remote
# Resource:: cpe_remote_pkg
#
# Copyright 2014, Mike Dodge
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

resource_name :cpe_remote_pkg
default_action :install

provides :cpe_remote_pkg, :os => 'darwin'
property :app, String, :name_property => true
property :checksum, String
property :cleanup, [TrueClass, FalseClass], :default => true
property :mpkg, [TrueClass, FalseClass], :default => false
property :pkg_name, String
property :receipt, String, :desired_state => false
property :remote, [TrueClass, FalseClass], :default => true
property :version, String

def backhauled?
  backhaul_osx = '/opt/facebook/ops/scripts/backhaul/.backhaul_running'
  backhaul_linux = '/var/lock/.backhaul_running'
  ::File.exists?(backhaul_osx) || ::File.exists?(backhaul_linux)
end

load_current_value do
  cmd = "pkgutil --pkg-info '#{receipt}'"
  version shell_out(cmd).stdout.to_s[/version: (.*)/, 1]
end

action :install do
  converge_if_changed :version do
    pkg_name = new_resource.app
    pkg_version_str = "-#{new_resource.version}"
    if new_resource.pkg_name
      pkg_name = new_resource.pkg_name
      pkg_version_str = ''
    end

    is_mpkg = new_resource.mpkg
    chef_cache = Chef::Config[:file_cache_path]

    # Download vars
    ext = is_mpkg ? 'zip' : 'pkg'
    download_file = "#{pkg_name}#{pkg_version_str}.#{ext}"
    download_file_path = "#{chef_cache}/#{download_file}"
    valid_url = true

    if new_resource.remote
      server = get_server
      pkg_source = gen_url(server, new_resource.app, download_file)

      valid_url = valid_url?(pkg_source)
      remote_file download_file do
        path download_file_path
        source pkg_source
        checksum new_resource.checksum unless is_mpkg
        backup !new_resource.cleanup
        only_if { valid_url }
      end
    end

    # Unzip if is_mpkg
    execute "Unzipping #{download_file_path}" do
      only_if { is_mpkg }
      only_if { valid_url }
      command "cd #{chef_cache}; unzip -o '#{download_file_path}'"
    end

    # install vars
    pkg_file = "#{pkg_name}#{pkg_version_str}.pkg"
    pkg_file_path = "#{chef_cache}/#{pkg_file}"
    pkg_on_disk = pkg_file_path
    if is_mpkg
      pkg_file = "#{pkg_name}#{pkg_version_str}.mpkg"
      pkg_file_path = "#{chef_cache}/#{pkg_name}/#{pkg_file}"
      pkg_on_disk = download_file_path
    end

    execute "Installing #{pkg_file}" do
      only_if { valid_url }
      only_if do
        # Comparing the Checksum Provided to the file downloaded
        checksum_ondisk = Chef::Digester.checksum_for_file(pkg_on_disk)
        Chef::Log.debug(
          "Provided checksum #{new_resource.checksum} == " +
          "File On Disk checksum #{checksum_ondisk}",
        )
        if new_resource.checksum != checksum_ondisk
          fail ArgumentError, 'Invalid Checksum, Checksum Mismatch'
        end
        true
      end
      command "installer -pkg '#{pkg_file_path}' -target /"
    end

    # Delete Zip if there is a ZIP
    file download_file_path do
      only_if { is_mpkg }
      only_if { valid_url }
      only_if { new_resource.cleanup }
      action :delete
      backup false
    end

    # Delete MPKG
    directory pkg_file_path do
      only_if { is_mpkg }
      only_if { valid_url }
      only_if { new_resource.cleanup }
      action :delete
      recursive true
    end

    # Delete PKG
    file pkg_file_path do
      not_if { is_mpkg }
      only_if { valid_url }
      only_if { new_resource.cleanup }
      action :delete
      backup false
    end
  end
end
