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
# Library:: chrome_windows

# This addition to the FB namespace is specific to managing Chrome enterprise
# settings on Windows.
module CPE
  # The Chef registry providers require the corresponding registry key types
  # (i.e. REG_DWORD, REG_STRING) to write the settings into the registry which
  # are explicitly laid out in this module.
  unless defined?(CPE::ChromeManagement)
    module ChromeManagement
      # This is the root registry key that will be used to prefix all of the
      # subsequent registry keys listed in this file.
      # You can store the keys either in HKEY_LOCAL_MACHINE or
      # HKEY_CURRENT_USER.
      # HKEY_LOCAL_MACHINE settings take precedence over user HKEY_CURRENT_USER
      # settings.
      def self.chrome_reg_root
        'HKLM\\Software\\Policies\\Google\\Chrome'.freeze
      end

      def self.chrome_reg_3rd_party_ext_root
        'HKLM\\Software\\Policies\\Google\\Chrome\\3rdparty\\extensions'.freeze
      end

      # These keys can be passed in an array of dictionaries and the resource
      # will call `.to_json` on them so that they actually work. Please confirm
      # in the documentation that you are creating the necessary data structure.
      JSONIFY_REG_KEYS = {
        'Chrome' => {
          'ManagedBookmarks' => :string,
        },
      }.freeze
    end
  end
end
