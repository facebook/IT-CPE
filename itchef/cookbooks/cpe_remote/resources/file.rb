# Cookbook Name:: cpe_remote
# Resource:: cpe_remote_file
#
# Copyright (c) Facebook, Inc. and its affiliates.
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

resource_name :cpe_remote_file
default_action :create
provides :cpe_remote_file

property :folder_name, String, :name_property => true
# see https://github.com/chef/chef/blob/ +
# f43371b231d7bb88c01618c90347cbb1fc96a393/lib/chef/resource/file.rb
property :atomic_update, [TrueClass, FalseClass],
         :default => lazy { Chef::Config[:file_atomic_update] },
         :desired_state => false
property :checksum, String
property :backup, [FalseClass, Integer],
         :default => false,
         :desired_state => false
property :file_name, String, :desired_state => false
property :file_url, String, :desired_state => false
property :group, [String, Integer]
property :mode, [String, Integer], :default => '0644', :coerce => proc { |m|
  ((m.respond_to?(:oct) ? m.oct : m.to_i) & 007777).to_s(8)
}
property :owner, [String, Integer]
property :path, String, :desired_state => false
property :headers, Hash, :desired_state => false

action_class do
  include CPE::Remote
end

load_current_value do |desired| # ~FC006
  path = desired.path
  if ::File.exist?(path)
    f_stat = ::File.stat(path)
    checksum_ondisk = Chef::Digester.checksum_for_file(path)
    checksum checksum_ondisk
    unless platform?('windows')
      begin
        current_user = ::Etc.getpwuid(f_stat.uid).name
      rescue ArgumentError
        current_user = f_stat.uid
      end
      owner current_user
      begin
        current_group = ::Etc.getgrgid(f_stat.gid).name
      rescue ArgumentError
        current_group = f_stat.gid
      end
      group current_group
      m = f_stat.mode
      mode "0#{(m & 07777).to_s(8)}"
    end
  end
end

action :create do
  return unless node['cpe_remote']['server_accessible']
  converge_if_changed do
    filename = new_resource.file_name ?
      new_resource.file_name : new_resource.folder_name
    file_source = new_resource.file_url ?
      new_resource.file_url : gen_url(new_resource.folder_name, filename)
    hders = new_resource.headers ?
      new_resource.headers : auth_headers(file_source, 'GET')
    node['cpe_remote']['additional_headers'].each do |k, v|
      hders[k] = v
    end

    # Delete symlink before creating remote file.
    # Using link resource vs force_unlink property due to bug see:
    # https://github.com/chef/chef/issues/4992
    link new_resource.path do
      only_if { ::File.symlink?(new_resource.path) }
      action :delete
    end

    # Download the remote file locally if file doesn't exist or checksum fails
    remote_file new_resource.path do
      only_if do
        CPE::Log.unless(
          "Failed to download remote file since url(#{file_source}) is invalid",
          :level => :warn,
          :type => 'cpe_remote_file',
          :action => "remote_file/#{filename}",
          :status => 'fail',
        ) { valid_url?(file_source) }
      end
      path new_resource.path if new_resource.path
      atomic_update new_resource.atomic_update
      source file_source
      mode new_resource.mode
      owner new_resource.owner
      group new_resource.group
      checksum new_resource.checksum
      backup new_resource.backup
      headers(hders) if hders
    end

    file_path = new_resource.path
    Chef.event_handler do
      on :resource_failed do |resource, _action, exception|
        if resource.to_s == "remote_file[#{file_path}]"
          CPE::Log.log(
            "#{filename} deployment to #{file_path} " +
            "failed with exception: #{exception}",
            :level => :error,
            :type => 'cpe_remote_file',
            :action => 'install',
            :status => 'fail',
          )
        end
      end
    end

    Chef.event_handler do
      on :resource_updated do |resource|
        if resource.to_s == "remote_file[#{file_path}]"
          CPE::Log.log(
            "#{filename} deployment to #{file_path} succeeded",
            :level => :debug,
            :type => 'cpe_remote_file',
            :action => 'install',
            :status => 'success',
          )
        end
      end
    end
  end
end
