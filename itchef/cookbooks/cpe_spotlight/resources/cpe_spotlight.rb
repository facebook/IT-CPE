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

# Cookbook Name:: cpe_spotlight
# Resource:: cpe_spotlight

resource_name :cpe_spotlight
provides :cpe_spotlight, :os => 'darwin'
default_action :run

action_class do
  def exclusion_list
    # Use PyObjC to call the Spotlight APIs directly
    shell_out(
      '/usr/bin/python -c "import objc; from Foundation import NSBundle; ' +
      "MD_bundle = NSBundle.bundleWithIdentifier_('com.apple.Metadata'); " +
      "functs = [('_MDCopyExclusionList', '@'), ('_MDSetExclusion', '@@I')]; " +
      'objc.loadBundleFunctions(MD_bundle, globals(), functs); ' +
      'current_exclusions = _MDCopyExclusionList(); ' +
      "print ','.join(current_exclusions)\"",
    ).stdout.chomp.split(',')
  end

  def list_from_disk
    spotlight_path = node['cpe_spotlight']['track_file']
    begin
      old_disklist = Chef::JSONCompat.from_json(::File.read(spotlight_path))
    rescue StandardError
      old_disklist = []
    end
    old_disklist
  end
end

action :run do
  # No exclusions, nothing to do
  return if node['cpe_spotlight']['exclusions'].empty?
  spotlight_path = node['cpe_spotlight']['track_file']
  # If all exclusions are already accounted for, nothing to do
  return if (node['cpe_spotlight']['exclusions'] - exclusion_list).empty?
  disklist = []
  # 1. Add attributes to spotlight
  node['cpe_spotlight']['exclusions'].uniq.each do |path|
    # Path must exist on disk
    unless ::File.exist?(path)
      node.default['cpe_spotlight']['exclusions'].delete(path)
      next
    end
    disklist << path
    # No need to add if it's already excluded
    next if exclusion_list.include?(path)
    add_cmd =
      '/usr/bin/python -c "import objc; from Foundation import NSBundle; ' +
      "MD_bundle = NSBundle.bundleWithIdentifier_('com.apple.Metadata'); " +
      "functs = [('_MDCopyExclusionList', '@'), ('_MDSetExclusion', '@@I')]; " +
      'objc.loadBundleFunctions(MD_bundle, globals(), functs); ' +
      "result = _MDSetExclusion(\'#{path}\', 1)\""
    execute "add_#{path}_to_spotlight" do
      command add_cmd
      action :run
    end
  end
  # 2. Read existing settings from disk
  old_disklist = list_from_disk
  # 3. Merge settings together
  pretty_settings =
    Chef::JSONCompat.to_json_pretty((disklist + old_disklist).uniq)
  # 4. Write attributes to file on disk
  file spotlight_path do
    content pretty_settings
    owner 'root'
    group 'wheel'
    mode '0644'
    action :create
  end
end

action :clean_up do
  spotlight_path = node['cpe_spotlight']['track_file']
  # 1. Read file on disk
  old_disklist = list_from_disk
  # 2. Remove list: item is an exclusion, but not in attributes and is on disk
  remove_list = exclusion_list - node['cpe_spotlight']['exclusions']
  remove_list.each do |path|
    # Only remove things we previously added with Chef
    next unless old_disklist.include?(path)
    remove_cmd =
      '/usr/bin/python -c "import objc; from Foundation import NSBundle; ' +
      "MD_bundle = NSBundle.bundleWithIdentifier_('com.apple.Metadata'); " +
      "functs = [('_MDCopyExclusionList', '@'), ('_MDSetExclusion', '@@I')]; " +
      'objc.loadBundleFunctions(MD_bundle, globals(), functs); ' +
      "result = _MDSetExclusion(\'#{path}\', 0)\""
    execute "remove_#{path}_from_spotlight" do
      command remove_cmd
      action :run
    end
  end
  # 3. Remove removed paths from disk
  # If disk contains contents of attributes, nothing to do
  return if old_disklist == node['cpe_spotlight']['exclusions']
  pretty_settings =
    Chef::JSONCompat.to_json_pretty(node['cpe_spotlight']['exclusions'])
  file spotlight_path do
    content pretty_settings
    owner 'root'
    group 'wheel'
    mode '0644'
    action :create
  end
end
