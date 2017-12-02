#
# Cookbook Name:: cpe_win_telemetry
# Recipe:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

return unless node.windows? && node.os_at_least?('10.0.15063')
cpe_win_telemetry 'Configure Windows Telemetry Settings'
