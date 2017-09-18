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

action_class do
  def gen_prompt(p_name, ph)
    icon = ph['icon'] ? ph['icon'] : node['cpe_prompt_user']['icon']
    type = ph['type'] ? ph['type'] : 'ok-msgbox'
    float = ph['float'] ? ph['float'] : true
    phash = {
      'program_arguments' => [],
      'run_at_load' => true,
      'type' => 'agent',
      'limit_load_to_session_type' => 'Aqua',
    }
    cmd = [
      node['cpe_prompt_user']['CocoaDialog'],
      type,
      '--title', ph['title'],
      '--text', ph['title'],
      '--icon-file', icon
    ]
    ptype_adds = []
    ptype_adds +=
      case type
      when 'ok-msgbox'
        [
          '--informative-text', ph['message']
        ]
      end
    ptype_adds.each { |i| cmd << i }
    cmd << '--float' if float
    cmd << '--no-cancel' if ph['no_cancel']
    # interval in mins
    phash['start_interval'] = ph['interval'] * 60 if ph['interval']
    phash['program_arguments'] = cmd
    ld_prefix = node['cpe_launchd']['prefix']
    p_name = p_name.tr(' ', '.')
    node.default['cpe_launchd']["#{ld_prefix}.#{p_name}"] = phash
  end
end

action :prompt do
  node['cpe_prompt_user']['prompts'].to_h.each { |k, v| gen_prompt(k, v) }
end
