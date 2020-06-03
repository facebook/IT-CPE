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

# Cookbook Name:: cpe_symlinks
# Resource:: default

resource_name :cpe_symlinks
provides :cpe_symlinks
default_action :create

# rubocop:disable Metrics/BlockLength
action :create do
  return if node['cpe_symlinks'].empty?
  cached_path =
    ::File.join(Chef::Config[:file_cache_path], '.chef-symlinks.json')
  cached_list = cached_on_disk(cached_path)
  symlink_list = []

  # Create symlinks on disk
  node['cpe_symlinks'].to_h.map.each do |target_dir, symlinks|
    symlinks.each do |target, source|
      next unless ::File.exist?(source)
      link ::File.join(target_dir, target) do
        to source
      end
      symlink_list << ::File.join(target_dir, target)
    end
  end

  # Cache list of symlinks to disk
  file cached_path do
    content Chef::JSONCompat.to_json_pretty(symlink_list.uniq)
    action :create
    owner node.root_user
    group node.root_group
    mode '755'
  end

  # Remove any symlinks on disk that have been unmanaged
  removal_list = cached_list.uniq - symlink_list.uniq
  unless removal_list.empty?
    removal_list.each do |symlink|
      link symlink do
        only_if { ::File.symlink?(symlink) }
        # TODO(dmk): Hack needed to rollout chefctl. Will delete after.
        not_if { symlink.eql?('/usr/local/bin/chefctl') }
        action :delete
      end
    end
  end
end

action_class do
  def cached_on_disk(cached_path)
    begin
      cached_list = Chef::JSONCompat.from_json(::File.read(cached_path))
    rescue
      cached_list = []
    end
    cached_list
  end
end
# rubocop:enable Metrics/BlockLength
