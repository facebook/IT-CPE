# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_chrome
# Resources:: cpe_chrome_cleanup
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_chrome_cleanup
default_action :execute

action :execute do
  chrome_cleanup
end

action_class do
  def chrome_cleanup
    case node['os']
    when 'darwin'
      return
    when 'linux'
      return
    when 'windows'
      uid = node.attr_lookup('cpe/person/uid')
      return if uid.nil?
      source = node['cpe_chrome']['profile']
      path = "HKEY_USERS\\#{uid}\\SOFTWARE\\Policies\\Google\\Chrome\\"
      unless registry_key_exists?(path)
        Chef::Log.info(
          "#{cookbook_name}: Google Chrome policies reg keys do not exists",
        )
        return
      end

      # Get current registry settings
      current_reg = get_current_reg(path, source)

      # Transform the data so it can be easily compared to hash in the node
      # attribute
      on_disk = transform_reg(current_reg)

      # Get the difference bewteen settings on disk vs desired settings
      reg_diff = compare_reg(on_disk, source)

      # Create a new hash with the differences which can be consumed by the
      # registry_key resource.
      reg_delete = get_reg_name(reg_diff, current_reg)

      reg_delete.each do |keys, vals|
        vals.each do |val|
          registry_key "#{path}\\#{keys}" do
            values val
            ignore_failure false
            action :delete
          end
        end
      end
    end
  end

  def get_current_reg(reg_path, reg)
    values = Hash.new { |h, k| h[k] = [] }
    reg_keys = reg.keys
    reg_keys.each do |key|
      values[key] = registry_get_values("#{reg_path}\\#{key}")
    end
    return values
  end

  def transform_reg(reg_keys)
    transform_reg = Hash.new { |h, k| h[k] = [] }
    reg_keys.each do |key, values|
      values.each do |value|
        if value[:data] == 0
          value[:data] = true
        elsif value[:data] == 1
          value[:data] = false
        elsif value[:data].is_a?(Integer)
          transform_reg[key] = value
        else
          transform_reg[key] << value[:data]
        end
      end
    end
    return transform_reg
  end

  def compare_reg(disk, source)
    reg_clean = Hash.new { |h, k| h[k] = [] }

    disk.each do |key, val|
      if val.class == Array
        diffs = disk[key] - source[key]
        diffs.each do |diff|
          reg_clean[key] << diff
        end
      end
    end
    return reg_clean
  end

  def get_reg_name(hashes, current_hash)
    delete_hash = Hash.new { |h, k| h[k] = [] }
    hashes.each do |keys, values|
      values.each do |value|
        delete_hash[keys] << current_hash[keys].select { |v| v[:data] == value }
      end
    end
    return delete_hash
  end
end
