#
# Cookbook Name:: cpe_chrome
# Libraries:: windows_chrome_settingv2
#
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

# This class is a superclass for implementing different types of chrome
# settings.
# All subclasses must implement `to_chef_reg_provider` to regurgitate something
# that chef can consume via the `registry_key` resource.
class WindowsChromeSettingV2
  attr_accessor :registry_location, :subkey, :iterable, :value, :type

  def initialize(registry_location, subkey, type, iterable)
    @registry_location = registry_location
    @subkey = subkey
    @type = type
    @iterable = iterable
  end

  def to_chef_reg_provider
    fail NotImplementedError, 'subclasses must implement this'
  end

  # This method is used to output a proper class constructor.
  # The generated string is set up in such a way that the linter will properly
  # autoformat it such that is will cooperate with our static analysis tooling.
  def generated_form
    initializer = self.instance_variables.each_with_object([]) do |v, a|
      value = self.instance_variable_get(v)
      if value.is_a?(String)
        a << "'#{value}'"
      elsif value.is_a?(Symbol)
        a << ":#{value}"
      elsif value.is_a?(NilClass)
        a << 'nil'
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
        a << value
      end
    end

    "#{self.class.name}.new(\n#{initializer.join(", \n")},)"
  end
end

class WindowsChromeIterableSetting < WindowsChromeSettingV2
  # Chrome settings in the registry with multiple entries are laid out
  # sequentially from [1...N]
  def to_chef_reg_provider
    list = []
    @value.each_with_index do |entry, index|
      list << { :name => (index + 1).to_s, :type => @type, :data => entry }
    end

    list
  end
end

class WindowsChromeFlatSetting < WindowsChromeSettingV2
  def to_chef_reg_provider
    if @value.is_a?(TrueClass)
      @value = 1
    elsif @value.is_a?(FalseClass)
      @value = 0
    end

    [{ :name => @subkey, :type => @type, :data => @value }]
  end
end
