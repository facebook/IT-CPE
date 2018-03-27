# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Cookbook Name:: cpe_remote
# Resource:: cpe_remote_zip
#
# Copyright 2017, Julie Wetherwax
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

resource_name :cpe_remote_zip
default_action :create
provides :cpe_remote_zip

property :folder_name, String, :name_property => true
property :zip_checksum, String
property :backup, [FalseClass, Integer],
         :default => false,
         :desired_state => false
property :zip_name, String, :desired_state => false
property :zip_url, String, :desired_state => false
property :extract_location, String, :desired_state => false
property :group, [String, nil]
property :mode, [String, Integer, nil], :default => '0644', :coerce =>
  proc { |m|
    ((m.respond_to?(:oct) ? m.oct : m.to_i) & 007777).to_s(8)
  }
property :owner, [String, nil]

action_class do
  include CPE::Remote
end

load_current_value do |desired| # ~FC006
  chef_cache = Chef::Config[:file_cache_path]
  extra_loco = extract_location.delete(':')
  zip_path = ::File.join(chef_cache, 'remote_zip', extra_loco, zip_name)

  if ::File.exists?(zip_path)
    checksum_ondisk = Chef::Digester.checksum_for_file(zip_path)
    zip_checksum checksum_ondisk
  end

  extract_path = desired.extract_location
  if ::File.exists?(extract_path)
    f_stat = ::File.stat(extract_path)
    unless platform?('windows')
      owner Etc.getpwuid(f_stat.uid).name
      group Etc.getgrgid(f_stat.gid).name
      m = f_stat.mode
      mode "0#{(m & 07777).to_s(8)}"
    end
  end
end

action :create do
  chef_cache = Chef::Config[:file_cache_path]
  extra_loco = new_resource.extract_location.delete(':')
  zip_path = ::File.join(
    chef_cache, 'remote_zip', extra_loco, new_resource.zip_name
  )

  return unless node['cpe_remote']['server_accessible']
  converge_if_changed do
    # @lint-ignore FBCHEFFoodcritic
    directory ::File.dirname(zip_path) do
      recursive true
    end

    cpe_remote_file folder_name do
      file_name zip_name
      mode new_resource.mode
      checksum new_resource.zip_checksum
      file_url new_resource.zip_url if new_resource.zip_url
      path zip_path
      backup new_resource.backup
      action :create
      notifies :install, 'package[unzip]', :immediately if node.linux?
      notifies :run, 'execute[extract_zip]' unless node.windows?
      notifies :run, 'powershell_script[extract_zip]' if node.windows?
    end

    package 'unzip' do
      only_if { node.linux? }
      action :nothing
    end

    execute 'extract_zip' do
      only_if { ::File.exist?(zip_path) }
      not_if { node.windows? }
      cwd extract_location
      command "unzip -o #{zip_path} -d #{extract_location}"
      action :nothing
    end

    if node.windows?
      cmd =
        "Expand-Archive -Path #{zip_path} " +
        "-DestinationPath #{extract_location} -Force"
      powershell_script 'extract_zip' do
        only_if { ::File.exist?(zip_path) }
        code cmd
        action :nothing
      end
    end

    # @lint-ignore FBCHEFFoodcritic
    directory extract_location do
      not_if { node.windows? }
      recursive true
      mode new_resource.mode
      owner new_resource.owner
      group new_resource.group
    end
  end
end
