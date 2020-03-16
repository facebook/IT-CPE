#!/opt/chefdk/embedded/bin/ruby

require 'pp'
require 'erb'
require 'inifile'
require 'json'
require_relative '../libraries/windows_chrome_settingv2'

reference_file = IniFile.load(File.join(__dir__, 'win_chrome_policy.reg'))
known_settings = {}

reference_file.sections.each do |s|
  is_iterable_setting = reference_file[s].
                        keys.
                        map { |x| /^"\d+"$/.match?(x) }.
                        all?

  if is_iterable_setting
    setting = s.split('\\').last
    known_settings[setting] = WindowsChromeIterableSetting.new(
      s,
      nil,
      :string,
      true,
    )
    next
  end

  reference_file[s].map do |k, v|
    # TODO: In Ruby 2.7 change this to use pattern matching when it is
    # supported.
    type = if v =~ /dword:.*/
             :dword
           else
             :string
           end
    setting = k.tr('"', '')
    known_settings[setting] = WindowsChromeFlatSetting.new(
      s, setting, type, false
    )
  end
end

template = <<-'EOF'
#
# Cookbook Name:: cpe_chrome
# Library:: gen_windows_chrome_known_settings
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
#
# rubocop:disable Metrics/LineLength
# @generated
require_relative 'windows_chrome_settingv2'

module CPE
  module ChromeManagement
    module KnownSettings
      GENERATED = {
      <% known_settings.map do |k,v| -%>
        "<%= k -%>" => <%= v.generated_form.tr('"', '') -%>,
      <% end -%>
      }.freeze
    end
  end
end
# rubocop:enable Metrics/LineLength
EOF

IO.write(
  File.join(
    __dir__,
    '..',
    'libraries',
    'gen_windows_chrome_known_settings.rb',
  ),
  ERB.new(template, nil, '-').result,
)
