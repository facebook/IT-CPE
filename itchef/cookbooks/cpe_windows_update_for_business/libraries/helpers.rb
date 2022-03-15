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

# Cookbook Name:: cpe_windows_update_for_business
# Library:: helpers

module CPE
  module WindowsUpdateForBusiness
    module ProductVersion
      WINDOWS_10 = 'Windows 10'.freeze
      WINDOWS_11 = 'Windows 11'.freeze

      def products
        [
          WINDOWS_10,
          WINDOWS_11,
        ].freeze
      end

      def valid?(v)
        products.include?(v) || v.nil?
      end

      module_function :valid?, :products
    end

    module BranchReadinessLevel
      INSIDER_FAST = 2
      INSIDER_SLOW = 4
      INSIDER_RELEASE = 8
      SEMI_ANNUAL_CHANNEL = 32

      def valid?(v)
        levels.include?(v) || v.nil?
      end

      def levels
        [
          INSIDER_FAST,
          INSIDER_SLOW,
          INSIDER_RELEASE,
          SEMI_ANNUAL_CHANNEL,
        ].freeze
      end

      module_function :valid?, :levels
    end

    # The information for this is contained in this link:
    # https://aka.ms/ReleaseInformationPage
    # Look in the "Version" column of the Semi-Annual Channel table.
    # Releases prior to 1803 do not recognize these registry settings and are
    # thus omitted.
    module ReleaseInformation
      VERSION_21H2 = '21H2'.freeze
      VERSION_21H1 = '21H1'.freeze
      VERSION_20H2 = '20H2'.freeze
      VERSION_20H1 = '2004'.freeze
      VERSION_19H2 = '1909'.freeze
      VERSION_19H1 = '1809'.freeze
      VERSION_18H2 = '1803'.freeze

      def releases
        [
          VERSION_21H2,
          VERSION_21H1,
          VERSION_20H2,
          VERSION_20H1,
          VERSION_19H2,
          VERSION_19H1,
          VERSION_18H2,
        ].freeze
      end

      def valid?(v)
        releases.include?(v)
      end

      module_function :valid?, :releases
    end

    KEY_PATH = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'.freeze

    def bool_from_int_or_nil(v)
      case v
      when nil
        false
      when 0
        false
      when 1
        true
      end
    end

    def load_current_registry_keys
      registry_hash = {}

      [KEY_PATH, "#{KEY_PATH}\\AU"].each do |path|
        begin
          registry_get_values(path).each do |i|
            registry_hash[path] = {} unless registry_hash[path]
            registry_hash[path].merge!({ i[:name] => i[:data] })
          end
        rescue Chef::Exceptions::Win32RegKeyMissing
          registry_hash[path] = {}
        end
      end

      registry_hash
    end
  end
end
