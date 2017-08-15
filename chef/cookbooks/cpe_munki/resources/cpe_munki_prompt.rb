# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8

# Cookbook Name:: cpe_munki
# Resource:: cpe_munki_prompt
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

require 'json'
resource_name :cpe_munki_prompt
default_action :run

# rubocop:disable Metrics/BlockLength
action :run do
  return unless node['cpe_munki']['prompt']['time']
  prompt_time = node['cpe_munki']['prompt']['time']
  valid_data = true
  loginfo = 'cpe_munki_prompt'

  # Make sure all the key/values in the hash are defined with appropriate values
  ['StartHour', 'EndHour', 'DayofWeek'].each do |k|
    unless prompt_time.key?(k)
      Chef::Log.info("#{loginfo}: Missing key #{k}")
      valid_data = false
      break
    end
    if prompt_time[k].nil?
      Chef::Log.info("#{loginfo}: Missing hash value for #{prompt_time}")
      valid_data = false
      break
    end
    unless prompt_time[k].is_a? Integer
      Chef::Log.info("#{loginfo}: #{prompt_time[k]} contains a non-Integer")
      valid_data = false
      break
    end
  end

  unless valid_data
    Chef::Log.info("#{loginfo}: Exiting invalid data in munki prompt file")
    return
  end

  hours_prompting = (prompt_time['EndHour'] - prompt_time['StartHour']).abs
  day_prompting = prompt_time['DayofWeek']

  Chef::Log.info("#{loginfo}: Custom Munki Time Prompt Found")

  # Only write the file if prompting on M-F and for at least 3 hours
  file '/Library/CPE/var/munki_prompt_config.json' do
    only_if { day_prompting >= 0 && day_prompting <= 4 }
    only_if { hours_prompting >= 3 }
    content Chef::JSONCompat.to_json_pretty(
      node['cpe_munki']['prompt']['time'],
    )
  end
end
# rubocop:enable Metrics/BlockLength
