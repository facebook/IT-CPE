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

# Cookbook Name:: cpe_launchd
# Resources:: default

resource_name :cpe_launchd
provides :cpe_launchd, :os => 'darwin'
default_action :run

action :run do
  node['cpe_launchd'].to_hash.each do |label, plist|
    next if label == 'prefix'
    label = process_label(label, plist)
    action, plist = process_plist(label, plist)
    launchd_resource(label, action, plist, nil)
  end
end

action :clean_up do
  process_plist_labels
  return if node['cpe_launchd']['__cleanup'].nil?
  node['cpe_launchd']['__cleanup'].each do |label, type|
    launchd_resource(label, 'delete', nil, type)
  end
end

def process_label(label, plist)
  return label if label.start_with?(node['cpe_launchd']['prefix'])
  # label does have the prefix so now we preocess
  append_to_cleanup(label, plist)
  if label.start_with?('com')
    label = delete_str_from_label(label, 'com')
  end
  label = "#{node['cpe_launchd']['prefix']}.#{label}"
  node.default['cpe_launchd'][label] = plist
  label
end

def process_plist(label, plist)
  plist['label'] = label
  action = plist['action'] ? plist['action'] : 'enable'
  plist.delete('action')
  return action, plist
end

def append_to_cleanup(label, plist_or_path)
  node.default['cpe_launchd']['__cleanup'] = {} unless
    node['cpe_launchd']['__cleanup']
  plist_type = nil # daemon
  if plist_or_path.is_a?(Hash) &&
    plist_or_path.include?('type') &&
    plist_or_path['type'] == 'agent'
    plist_type = 'agent'
  end
  if plist_or_path.is_a?(String)
    plist_type = 'agent' if plist_or_path.downcase.include?('launchagent')
  end
  node.default['cpe_launchd']['__cleanup'][label] = plist_type
end

def delete_str_from_label(label, string)
  name = label.split('.')
  name.delete(string)
  name.join('.')
end

def launchd_resource(label, action, plist, ld_type)
  return unless label
  res = Chef::Resource::Launchd.new(label, run_context)
  unless plist.nil?
    if plist.key?('only_if')
      unless plist['only_if'].class == Proc
        fail 'cpe_launchd\'s only_if requires a Proc'
      end
      unless plist['only_if'].call
        Chef::Log.debug("cpe_launchd: Not including #{label}" +
                        'due to only_if')
        return
      end
    end
    plist.to_hash.each do |key, val|
      next if key == 'only_if'
      res.send(key.to_sym, val)
    end
  end
  res.type(ld_type) if ld_type
  res.run_action action
  res
end

PLIST_DIRS = %w{/Library/LaunchAgents /Library/LaunchDaemons}.freeze
def find_managed_plist_labels
  plists = PLIST_DIRS.inject([]) do |results, dir|
    edir = ::File.expand_path(dir)
    entries = Dir.glob(
      "#{edir}/*#{Chef::Util::PathHelper.escape_glob(
        node['cpe_launchd']['prefix'],
      )}*.plist",
    )
    entries.any? ? results << entries : results
  end
  plists.flatten
end

def process_plist_labels
  plists = find_managed_plist_labels
  return if plists.nil?
  plists.map! do |full_daemon_path|
    label = full_daemon_path.split('/')[-1]
    label = delete_str_from_label(label, 'plist')
    unless node['cpe_launchd'].keys.include?(label)
      append_to_cleanup(label, full_daemon_path)
    end
  end
end
