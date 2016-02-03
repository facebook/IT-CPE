# Encoding: utf-8
# Cookbook Name:: remote
# Provider:: pkg
#
# Copyright 2016, Mike Dodge
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

include Chef::Mixin::ShellOut

def load_current_resource
  @pkg = Chef::Resource::RemotePkg.new(new_resource.name)
  @pkg.app(new_resource.app)
  Chef::Log.debug("Checking for application #{new_resource.app}")
  @pkg.installed(installed?)
end

action :install do
  unless @pkg.installed

    pkg_name = new_resource.app
    pkg_version_str = "-#{new_resource.version}"
    chef_cache = Chef::Config[:file_cache_path]

    # Download vars
    download_file = "#{pkg_name}#{pkg_version_str}.pkg"
    download_file_path = "#{chef_cache}/#{download_file}"

    if new_resource.remote
      pkg_source = gen_url(get_server, pkg_name, download_file)
      Chef::Log.info(pkg_source)

      remote_file download_file do
        path download_file_path
        source pkg_source
        checksum new_resource.checksum
        backup !new_resource.cleanup
      end
    end

    # install vars
    pkg_file = "#{pkg_name}#{pkg_version_str}.pkg"
    pkg_on_disk = "#{chef_cache}/#{pkg_file}"

    execute "Installing #{pkg_file}" do
      only_if do
        # Comparing the Checksum Provided to the file downloaded
        checksum_ondisk = Chef::Digester.checksum_for_file(pkg_on_disk)
        Chef::Log.debug(
          "Provided checksum #{new_resource.checksum} == " +
          "File On Disk checksum #{checksum_ondisk}"
        )
        if new_resource.checksum != checksum_ondisk
          fail ArgumentError, 'Invalid Checksum, Checksum Mismatch'
        end
        true
      end
      command "installer -pkg '#{pkg_on_disk}' -target /"
    end

    # Delete PKG
    file pkg_file_path do
      only_if { new_resource.cleanup }
      action :delete
      backup false
    end
  end
end

private

def installed?
  receipt = new_resource.receipt
  if shell_out("pkgutil --pkgs='#{new_resource.receipt}'").exitstatus == 0
    cmd = "pkgutil --pkg-info '#{new_resource.receipt}'"
    if shell_out(cmd).stdout.include?("version: #{new_resource.version}")
      msg = "Already installed; run \"sudo pkgutil --forget '#{receipt}'\""
      Chef::Log.info(msg)
      return true
    end
  end
  return false
end
