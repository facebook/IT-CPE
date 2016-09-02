# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8
#
# Cookbook Name:: cpe_spotlight
# Resource:: cpe_spotlight
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_spotlight
default_action :run

action :run do
  # No exclusions, nothing to do
  return if node['cpe_spotlight']['exclusions'].empty?
  spotlight_path = '/var/chef/.chef-spotlight.json'
  # If all exclusions are already accounted for, nothing to do
  return if (node['cpe_spotlight']['exclusions'] - exclusion_list).empty?
  disklist = []
  # 1. Add attributes to spotlight
  node['cpe_spotlight']['exclusions'].each do |path|
    # Path must exist on disk
    unless ::File.exist?(path)
      ::Chef::Log.warn("cpe_spotlight: #{path} not found, not excluding")
      node['cpe_spotlight']['exclusions'].delete(path)
      next
    end
    disklist << path
    # No need to add if it's already excluded
    next if exclusion_list.include?(path)
    ::Chef::Log.info("cpe_spotlight: Adding #{path} to exclusions list")
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
  # 2. Read existing settings first
  old_disklist = list_from_disk
  # 3. Merge settings together
  pretty_settings =
    Chef::JSONCompat.to_json_pretty((disklist + old_disklist).uniq)
  # 4. Write attributes to file on disk
  file spotlight_path do
    content pretty_settings
    action :create
  end
end

action :clean_up do
  spotlight_path = '/var/chef/.chef-spotlight.json'
  # 1. Read file on disk
  old_disklist = list_from_disk
  # 2. Remove list: item is an exclusion, but not in attributes and is on disk
  remove_list = exclusion_list - node['cpe_spotlight']['exclusions']
  remove_list.each do |path|
    # Only remove things we previously added with Chef
    next unless old_disklist.include?(path)
    ::Chef::Log.info("cpe_spotlight: Removing #{path} from exclusions list")
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
    action :create
  end
end

def exclusion_list
  Mixlib::ShellOut.new(
    '/usr/bin/python -c "import objc; from Foundation import NSBundle; ' +
    "MD_bundle = NSBundle.bundleWithIdentifier_('com.apple.Metadata'); " +
    "functs = [('_MDCopyExclusionList', '@'), ('_MDSetExclusion', '@@I')]; " +
    'objc.loadBundleFunctions(MD_bundle, globals(), functs); ' +
    'current_exclusions = _MDCopyExclusionList(); ' +
    "print ','.join(current_exclusions)\"",
  ).run_command.stdout.chomp.split(',')
end

def list_from_disk
  spotlight_path = '/var/chef/.chef-spotlight.json'
  begin
    old_disklist = Chef::JSONCompat.from_json(::File.read(spotlight_path))
  rescue
    old_disklist = []
  end
  old_disklist
end
