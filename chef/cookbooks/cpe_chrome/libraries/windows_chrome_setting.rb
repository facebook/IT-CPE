#
# Cookbook Name:: cpe_browsers
# Library:: windows_chrome_setting
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
require_relative 'chrome_windows'

# This class is an abstraction around what constitutes a Chrome setting in
# Windows. Since Windows does all its magic in the registry, the class provides
# a mechanism to ingest a hash entry that contains the desired setting. The
# class will then figure out relevant information about the setting to provide
# to the Chef registry_key resource.
class WindowsChromeSetting
  include FB::ChromeManagement
  def initialize(setting, forced = false)
    hkey_root = forced ? 'HKEY_LOCAL_MACHINE' : 'HKEY_CURRENT_USER'
    @forced = forced
    @name = setting.keys.first
    @data = setting.values.first

    reg_entry = construct_reg_key_path(setting.keys.first)
    @fullpath = "#{hkey_root}\\#{reg_entry.keys.first}"
    @path = @fullpath.split(@name).first.chop
    @type = reg_entry.values.first
  end

  attr_reader :path, :fullpath, :type, :data, :name, :scope, :forced

  # This method will output a hash that can be consumed by the chef registry_key
  # resource.
  def to_chef_reg_provider
    # Chrome settings in the registry with multiple entries are laid out
    # sequentially from [1...N]
    if data_has_multiple_entries?
      list = []
      @data.each_with_index do |entry, index|
        list << { :name => (index + 1).to_s, :type => @type, :data => entry }
      end
      list
    else
      if @data.is_a? TrueClass
        @data = 0
      elsif @data.is_a? FalseClass
        @data = 1
      end
      { :name => @name, :type => @type, :data => @data }
    end
  end

  # If you want to redirect to a user's HKEY_USER Registry Hive you can call
  # this method to shuffle the keys around
  def sid(id)
    if id.nil? || id.empty?
      return self
    end

    regex = /HKEY_CURRENT_USER|HKEY_LOCAL_MACHINE/
    replacement = "HKEY_USERS\\#{id}"

    @path.gsub!(regex, replacement)
    @fullpath.gsub!(regex, replacement)

    self
  end

  def empty?
    @data.empty?
  end

  private

  # Used for when the key is in the above defined hashes is in fact just the
  # root Chrome key.
  def chrome_root?(key = @fullpath)
    key.split('\\').include?('Chrome')
  end

  # Returns true if the data contained in the key has multiple entries, false
  # otherwise.
  def data_has_multiple_entries?
    @data.is_a? Array
  end

  # Walks the available configuration to determine where the full registry path
  # is.
  def construct_reg_key_path(key = @name)
    if ENUM_REG_KEYS.keys.include?(key)
      return { "#{CHROME_REG_ROOT}\\#{key}" => ENUM_REG_KEYS[key] }
    elsif in_complex_key?
      return lookup_complex(key)
    end
  end

  def lookup_complex(key)
    if chrome_root?(key)
      { CHROME_REG_ROOT => COMPLEX_REG_KEYS[which_complex_key][key] }
    else
      {
        "#{CHROME_REG_ROOT}\\#{key}" =>
          COMPLEX_REG_KEYS[which_complex_key][key],
      }
    end
  end

  # Returns true if the setting is located in the complex registry keys hash,
  # false otherwise.
  def in_complex_key?(key = @name)
    return true if COMPLEX_REG_KEYS['Chrome'].include?(key)
    return true if COMPLEX_REG_KEYS['Recommended'].include?(key)
    false
  end

  # Returns which complex key the setting is located under.
  def which_complex_key
    return 'Chrome' if COMPLEX_REG_KEYS['Chrome'].include?(@name)
    return 'Recommended' if COMPLEX_REG_KEYS['Recommended'].include?(@name)
  end
end
