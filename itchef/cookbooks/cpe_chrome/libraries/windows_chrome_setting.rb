# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Cookbook Name:: cpe_browsers
# Library:: windows_chrome_setting

require_relative 'chrome_windows'

# This class is an abstraction around what constitutes a Chrome setting in
# Windows. Since Windows does all its magic in the registry, the class provides
# a mechanism to ingest a hash entry that contains the desired setting. The
# class will then figure out relevant information about the setting to provide
# to the Chef registry_key resource.
class WindowsChromeSetting
  include CPE::ChromeManagement
  def initialize(setting, suffix_reg_path = nil, forced = false)
    @forced = forced
    @name = setting.keys.first
    @data = setting.values.first

    reg_entry = construct_reg_key_path(setting.keys.first, suffix_reg_path)
    @fullpath = reg_entry.keys.first.to_s
    @type = reg_entry.values.first

    p = @fullpath.split(@name)
    @path = if p.size == 1
              p.first.split('\\')[0..-1].join('\\')
            else
              p.first&.chop
            end
  end

  attr_reader :path, :fullpath, :type, :data, :name, :scope, :forced

  # This method will output a hash that can be consumed by the chef registry_key
  # resource.
  def to_chef_reg_provider
    if in_json_key?
      return { :name => @name, :type => @type, :data => @data.to_json }
    end

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
  def construct_reg_key_path(key = @name, suffix_path = nil)
    if ENUM_REG_KEYS.keys.include?(key)
      {
        "#{CPE::ChromeManagement.chrome_reg_root}\\#{key}" =>
          ENUM_REG_KEYS[key],
      }
    elsif in_json_key?
      {
        CPE::ChromeManagement.chrome_reg_root =>
          JSONIFY_REG_KEYS[which_json_key][key],
      }
    elsif in_complex_key?
      lookup_complex(key)
    elsif !suffix_path.nil?
      # This is only applicable in case of ExtensionSettings. The type is always
      # string
      {
        "#{CPE::ChromeManagement.chrome_reg_root}\\#{suffix_path}" => :string,
      }
    else
      Chef::Log.warn("#{key} is not a supported setting")
      {}
    end
  end

  def lookup_complex(key)
    if chrome_root?(key)
      {
        CPE::ChromeManagement.chrome_reg_root =>
          COMPLEX_REG_KEYS[which_complex_key][key],
      }
    else
      {
        "#{CPE::ChromeManagement.chrome_reg_root}\\#{key}" =>
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

  # Returns true if the setting is located in a registry key hash that should be
  # a JSON value, false otherwise.
  def in_json_key?(key = @name)
    return true if JSONIFY_REG_KEYS['Chrome'].include?(key)
    false
  end

  # Returns which JSON key the setting is located under.
  def which_json_key
    return 'Chrome' if JSONIFY_REG_KEYS['Chrome'].include?(@name)
  end
end
