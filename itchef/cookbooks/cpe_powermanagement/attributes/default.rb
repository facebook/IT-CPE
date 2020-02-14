#
# Cookbook Name:: cpe_powermanagement
# Attributes:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

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
