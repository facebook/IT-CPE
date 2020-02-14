#
# Cookbook Name:: cpe_powermanagement
# Attributes:: default
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
# These keys are named after the keys found in:
# `defaults read \
#  /Library/Preferences/SystemConfiguration/com.apple.PowerManagement`
# These keys are the _only_ options supported for management.
# Do not add arbitrary keys.

default['cpe_powermanagement'] = {
  'ACPower' => {
    'Automatic Restart On Power Loss' => nil, # bool
    'Disk Sleep Timer' => nil, # int (minutes)
    'Display Sleep Timer' => nil, # int (minutes)
    'Sleep On Power Button' => nil, # bool
    'System Sleep Timer' => nil, # int (minutes)
    'Wake On LAN' => nil, # bool
    'RestartAfterKernelPanic' => nil, # bool
  },
  'Battery' => {
    'Automatic Restart On Power Loss' => nil, # bool
    'Disk Sleep Timer' => nil, # int (minutes)
    'Display Sleep Timer' => nil, # int (minutes)
    'Sleep On Power Button' => nil, # bool
    'System Sleep Timer' => nil, # int (minutes)
    'Wake On LAN' => nil, # bool
    'RestartAfterKernelPanic' => nil, # bool
  },
}
