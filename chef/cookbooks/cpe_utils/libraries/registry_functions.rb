# Cookbook Name:: cpe_utils
# Library::registry_functions
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

module CPE
  module WindowsRegistry
    # Function which will return a hash which can be consumed by the values
    # property of the registry_key resrouce.  Provide the function the hash and
    # data_type of the registry key if needed.  We will try and automatically
    # detect the data_type, however please verify the returned hash is correct
    # as data_type detection needs to be refined for all edge cases.
    def create_registry_hash(data)
      hash = []
      data.each do |name, value|
        data_type = reg_data_type(value)
        hash << { :name => name, :type => data_type, :data => value }
      end
      hash
    end

    # First pass at determining data type for registry, verify returned data
    # type is correct as type detection needs to be refined for all edge cases.
    def reg_data_type(data)
      case data
      when String
        data_type = :string
        if data.include?('%')
          data_type = :expand_string
        end
      when Integer
        if data < (2**62 - 1)
          data_type = :dword
        else
          data_type = :qword
        end
      end
      data_type
    end
  end
end

Chef::Recipe.send(:include, ::CPE::WindowsRegistry)
Chef::Resource.send(:include, ::CPE::WindowsRegistry)
Chef::Provider.send(:include, ::CPE::WindowsRegistry)
