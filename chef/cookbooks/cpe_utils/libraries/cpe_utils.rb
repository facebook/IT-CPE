# Cookbook Name:: cpe_utils
# Library::cpe_utils
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

module CPE
  # Various utility grab-bag.
  module Utils
    def root_owner
      value_for_platform(
        'windows' => { 'default' => 'Administrator' },
        'default' => 'root'
      )
    end

    def root_group
      value_for_platform(
        ['openbsd', 'freebsd', 'mac_os_x'] => { 'default' => 'wheel' },
        'windows' => { 'default' => 'Administrators' },
        'default' => 'root'
      )
    end
  end
end

Chef::Recipe.send(:include, ::CPE::Utils)
Chef::Resource.send(:include, ::CPE::Utils)
Chef::Provider.send(:include, ::CPE::Utils)
