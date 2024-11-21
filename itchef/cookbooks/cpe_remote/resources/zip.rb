# Cookbook Name:: cpe_remote
# Resource:: cpe_remote_zip
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

resource_name :cpe_remote_zip
default_action :create
provides :cpe_remote_zip
unified_mode(false) if Chef::VERSION >= 18

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

load_current_value do |desired| # rubocop:disable Chef/Correctness/ServiceResource
  chef_cache = Chef::Config[:file_cache_path]
  extra_loco = extract_location.delete(':')
  zip_path = ::File.join(chef_cache, 'remote_zip', extra_loco, zip_name)

  if ::File.exist?(zip_path)
    checksum_ondisk = Chef::Digester.checksum_for_file(zip_path)
    zip_checksum checksum_ondisk
  end

  extract_path = desired.extract_location
  if ::File.exist?(extract_path)
    f_stat = ::File.stat(extract_path)
    unless platform?('windows')
      owner ::Etc.getpwuid(f_stat.uid).name
      group ::Etc.getgrgid(f_stat.gid).name
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
    base_filename = ::File.basename(zip_path)
    # @lint-ignore FBCHEFFoodcritic
    directory ::File.dirname(zip_path) do # rubocop:disable Chef/Meta/RequireOwnerGroupMode
      recursive true # rubocop: disable Chef/Meta/NoRecursiveDirs
    end

    if node.windows?
      zip_cmd = CPE::Helpers.sevenzip_cmd
      return if CPE::Log.if(
        "#{cookbook_name}: No local 7zip command found",
        :level => :warn,
        :type => 'cpe_remote_zip',
        :action => 'install',
        :status => 'fail',
      ) { zip_cmd.nil? }

      # Create the destination dir first
      directory 'dest_folder' do
        only_if { ::File.exist?(zip_path) }
        path new_resource.extract_location
        owner 'Administrators'
        group 'Administrators'
        mode 0755
        action :nothing
      end
      # Decompress zip file via shell.
      powershell_script "decompress_#{base_filename}" do
        only_if { ::File.exist?(zip_path) }
        only_if { ::Dir.exist?(new_resource.extract_location) }
        cwd new_resource.extract_location
        code "#{zip_cmd} -y x #{zip_path}"
        action :nothing
      end
    end

    cpe_remote_file new_resource.folder_name do
      file_name new_resource.zip_name
      mode new_resource.mode
      checksum new_resource.zip_checksum
      file_url new_resource.zip_url if new_resource.zip_url
      path zip_path
      backup new_resource.backup
      unless node['cpe_remote']['additional_headers'].empty?
        headers node['cpe_remote']['additional_headers']
      end
      action :create
      notifies :install, 'package[unzip]', :immediately if node.linux?
      notifies :run, 'execute[extract_zip]' unless node.windows?
      if node.windows?
        owner 'Administrators'
        group 'Administrators'
        notifies :create, 'directory[dest_folder]'
        notifies :run, "powershell_script[decompress_#{base_filename}]"
      end
    end

    package 'unzip' do # rubocop:disable Chef/Meta/PackageInstallsHaveVersionOrAction, Chef/Meta/CPEPackageResource
      only_if { node.linux? }
      action :nothing
    end

    execute 'extract_zip' do
      only_if { ::File.exist?(zip_path) }
      not_if { node.windows? }
      cwd new_resource.extract_location
      command "unzip -o #{zip_path} -d #{new_resource.extract_location}"
      action :nothing
    end

    directory new_resource.extract_location do
      not_if { node.windows? }
      recursive true # rubocop:disable Chef/Meta/NoRecursiveDirs
      mode new_resource.mode
      owner new_resource.owner
      group new_resource.group
    end

    resource_name = new_resource.name
    zip_name = new_resource.zip_name
    extract_location = new_resource.extract_location
    Chef.event_handler do
      on :resource_failed do |resource, _action, exception|
        if resource.to_s == "cpe_remote_zip[#{resource_name}]"
          CPE::Log.log(
            "#{zip_name} deployment to #{extract_location} " +
            "failed with exception: #{exception}",
            :level => :debug,
            :type => 'cpe_remote_zip',
            :action => 'install',
            :status => 'fail',
          )
        end
      end
    end

    Chef.event_handler do
      on :resource_updated do |resource|
        if resource.to_s == "cpe_remote_zip[#{resource_name}]"
          CPE::Log.log(
            "#{zip_name} deployment to #{extract_location} succeeded",
            :level => :error,
            :type => 'cpe_remote_zip',
            :action => 'install',
            :status => 'success',
          )
        end
      end
    end
  end
end
