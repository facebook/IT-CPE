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
# Spec:: windows_chrome_setting

require 'json'
require_relative 'spec_helper'

RSpec.describe WindowsChromeSetting do
  JSON_EXAMPLE_DATA = [
    {
      :toplevel_name => 'My managed bookmarks folder',
    },
    {
      :url => 'google.com',
      :name => 'Google',
    },
    {
      :url => 'youtube.com',
      :name => 'Youtube',
    },
    {
      :name => 'Chrome links',
      :children => [
        {
          :url => 'chromium.org',
          :name => 'Chromium',
        },
        {
          :url => 'dev.chromium.org',
          :name => 'Chromium Developers',
        },
      ],
    },
  ].freeze
  settings = {
    'empty_setting' => { 'ExtensionInstallBlacklist' => [] },
    'doc_setting' => { 'AlternateErrorPagesEnabled' => [true] },
    'json_setting' => { 'ManagedBookmarks' => JSON_EXAMPLE_DATA },
    'example_setting' => {
      'ExtensionInstallForcelist' => ['ncfpggehkhmjpdjpefomjchjafhmbnai;bacon'],
    },
  }

  extension_setting = {
    'suffix_path' => 'ExtensionSettings\ncfpggehkhmjpdjpefomjchjafhmbnai',
    'setting' => { 'installation_mode' => 'removed' },
    'expected' => {
      'name' => 'installation_mode',
      'type' => :string,
      'fullpath' => 'HKLM\Software\Policies\Google\Chrome\ExtensionSettings' +
                '\ncfpggehkhmjpdjpefomjchjafhmbnai',
    },
  }

  expected_results = {
    'empty_setting' => {
      'header' => 'A simple setting that has no value',
      'name' => 'ExtensionInstallBlacklist',
      'type' => :string,
      'data' => [],
      'expected_class' => 'Array',
      'fullpath' => 'HKLM\Software\Policies\Google\Chrome' +
                '\ExtensionInstallBlacklist',
      'fullpath_forced' =>
        'HKLM\Software\Policies\Google\Chrome' +
        '\ExtensionInstallBlacklist',
      'path' => 'HKLM\Software\Policies\Google\Chrome',
    },
    'example_setting' => {
      'header' =>
        'A simple setting I arbitrarily grabbed from the attributes ' +
        'file',
      'name' => 'ExtensionInstallForcelist',
      'type' => :string,
      'data' => ['ncfpggehkhmjpdjpefomjchjafhmbnai;bacon'],
      'expected_class' => 'Array',
      'fullpath' => 'HKLM\Software\Policies\Google\Chrome' +
                '\ExtensionInstallForcelist',
      'fullpath_forced' =>
        'HKLM\Software\Policies\Google\Chrome' +
        '\ExtensionInstallForcelist',
      'path' => 'HKLM\Software\Policies\Google\Chrome',
    },
    'doc_setting' => {
      'header' => 'A more complex setting I grabbed from the Chrome ' +
        'documentation',
      'name' => 'AlternateErrorPagesEnabled',
      'type' => :dword,
      'data' => [true],
      'expected_class' => 'Array',
      'fullpath' => 'HKLM\Software\Policies\Google\Chrome' +
                '\AlternateErrorPagesEnabled',
      'fullpath_forced' =>
        'HKLM\Software\Policies\Google\Chrome' +
        '\AlternateErrorPagesEnabled',
      'path' => 'HKLM\Software\Policies\Google\Chrome',
    },
    'json_setting' => {
      'header' => 'gh-issue-224 - A value that needs to be a JSON string',
      'name' => 'ManagedBookmarks',
      'type' => :string,
      'data' => JSON_EXAMPLE_DATA,
      'expected_class' => 'Array',
      'fullpath' => 'HKLM\Software\Policies\Google\Chrome',
      'fullpath_forced' => 'HKLM\Software\Policies\Google\Chrome',
      'path' => 'HKLM\Software\Policies\Google\Chrome',
      'output' => JSON_EXAMPLE_DATA.to_json,
    },
  }

  shared_examples 'the chrome setting creates the key in HKLM' do
    context 'setting is forced' do
      let(:result) do
        'HKLM\\Software\\Policies\\Google\\Chrome' +
        '\ExtensionInstallForcelist'
      end
      subject do
        WindowsChromeSetting.new(settings['example_setting'], nil, true)
      end
      it { should eq result }
    end
    context 'setting is not forced' do
      let(:result) do
        'HKLM\\Software\\Policies\\Google\\Chrome' +
        '\ExtensionInstallForcelist'
      end
      subject do
        WindowsChromeSetting.new(settings['example_setting'], nil, false)
      end
      it { should eq result }
    end
  end
  context 'A simple setting that has no value' do
    context 'its data' do
      subject { WindowsChromeSetting.new(settings['empty_setting']).data }
      it { should be_a Array }
      it { should eql [] }
    end
    context 'is the setting marked as empty?' do
      subject { WindowsChromeSetting.new(settings['empty_setting']).empty? }
      it { should be true }
    end
  end
  context 'A setting with a suffix path' do
    context 'registry key name' do
      subject do
        WindowsChromeSetting.new(
          extension_setting['setting'],
          extension_setting['suffix_path'],
        ).name
      end
      it { should eq extension_setting['expected']['name'] }
    end
    context 'registry key fullpath' do
      subject do
        WindowsChromeSetting.new(
          extension_setting['setting'],
          extension_setting['suffix_path'],
        ).fullpath
      end
      it { should eq extension_setting['expected']['fullpath'] }
    end
    context 'registry key type' do
      subject do
        WindowsChromeSetting.new(
          extension_setting['setting'],
          extension_setting['suffix_path'],
        ).type
      end
      it { should eq extension_setting['expected']['type'] }
    end
  end
  settings.each_key do |setting|
    context expected_results['header'] do
      context 'registry key name' do
        subject { WindowsChromeSetting.new(settings[setting]).name }
        it { should eq expected_results[setting]['name'] }
      end
      context 'registry key path' do
        subject { WindowsChromeSetting.new(settings[setting]).path }
        it { should eq expected_results[setting]['path'] }
      end
      context 'registry key fullpath' do
        subject { WindowsChromeSetting.new(settings[setting]).fullpath }
        it { should eq expected_results[setting]['fullpath'] }
      end
      context 'registry key fullpath forced' do
        subject do
          WindowsChromeSetting.new(settings[setting], nil, true).fullpath
        end
        it { should eq expected_results[setting]['fullpath_forced'] }
      end
      context 'registry key type' do
        subject { WindowsChromeSetting.new(settings[setting]).type }
        it { should eq expected_results[setting]['type'] }
      end
      context 'registry key data' do
        subject { WindowsChromeSetting.new(settings[setting]).data }
        it { should eq expected_results[setting]['data'] }
        it do
          should be_a Kernel.
            const_get(expected_results[setting]['expected_class'])
        end
      end
      if expected_results[setting]['output']
        subject do
          WindowsChromeSetting.new(settings[setting]).
            to_chef_reg_provider[:data]
        end
        context 'chef_to_reg_provider data output should equal' do
          it { should eql expected_results[setting]['output'] }
        end
      end
    end
  end
end
