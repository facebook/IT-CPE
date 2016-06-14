#
# Cookbook Name:: cpe_prompt_user
# Resource:: cpe_prompt_user
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_prompt_user
default_action :prompt


# Required properties
property :prompt_name, String, name_property: true
property :message, String # informative-text
# optional
property :float, [ TrueClass, FalseClass ], default: true
property :icon, String, default: node['cpe_prompt_user']['icon'] # icon-file
property :interval, [ Integer, FalseClass ], default: false
property :no_cancel, [ TrueClass, FalseClass ], default: true
property :title, String, default: 'Facebook IT Says:' # title, text
property :type, String, default: 'ok-msgbox' # type of prompt

action :prompt do
  phash = {
    'program_arguments' => [],
    'run_at_load' => true,
    'type' => 'agent',
    'limit_load_to_session_type' => 'Aqua',
  }
  cmd = [
    node['cpe_prompt_user']['CocoaDialog'],
    type,
    '--title', title,
    '--text', title,
    '--icon-file', icon,
  ]
  ptype_adds = case type
  when 'ok-msgbox'
    [
      '--informative-text', message,
    ]
  end
  ptype_adds.each { |i| cmd << i}
  cmd << '--float' if float
  cmd << '--no-cancel' if no_cancel
  phash['start_interval'] = interval *60 if interval # interval in mins
  phash['program_arguments'] = cmd
  ld_prefix = node['cpe_launchd']['prefix']
  prompt_name = name.gsub(' ', '.')
  node.default['cpe_launchd']["#{ld_prefix}.#{prompt_name}"] = phash
end

