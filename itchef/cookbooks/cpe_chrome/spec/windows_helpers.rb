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

# Cookbook Name:: cpe_chrome
# Spec:: windows_helpers

require 'chefspec'
require_relative '../libraries/windows_chrome_settingv2'
require_relative '../libraries/gen_windows_chrome_known_settings'
require_relative '../libraries/chrome_windows'
require_relative '../libraries/windows_helpers'

def default_settings
  {
    'cpe_chrome' => {
      'profile' => {
        'ExtensionInstallBlocklist' => ['fake_extension_id'],
        'TotalMemoryLimitMb' => 512,
      },
    },
  }
end

describe CPE::WindowsChromeHelpers do
  let(:wch) { Class.new { extend CPE::WindowsChromeHelpers } }

  context 'set_reg_settings' do
    it 'converts set APIs to WindowsChromeSettings' do
      fake_node = default_settings
      settings = wch.set_reg_settings(fake_node)

      expect(settings[0]).to be_instance_of(WindowsChromeIterableSetting)
      expect(settings[0].value).to eq(fake_node['cpe_chrome']['profile']['ExtensionInstallBlocklist'])

      expect(settings[1]).to be_instance_of(WindowsChromeFlatSetting)
      expect(settings[1].value).to eq(fake_node['cpe_chrome']['profile']['TotalMemoryLimitMb'])
    end
  end

  context 'policies_to_remove' do
    it 'removes modified settings' do
      fake_node = default_settings
      invalid_itter_setting = [{ :name => '1', :type => :string, :data => 'modifiedextensionid' }]
      invalid_flat_setting = [{ :name => 'TotalMemoryLimitMb', :type => :dword, :data => 0 }]
      allow(wch).to receive(:registry_get_values).and_raise(Chef::Exceptions::Win32RegKeyMissing)
      allow(wch).to receive(:registry_get_values).with(
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist',
      ).and_return(invalid_itter_setting)

      allow(wch).to receive(:registry_get_values).with(
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome',
      ).and_return(invalid_flat_setting)

      wch.set_reg_settings(fake_node)

      doomed_policies = wch.policies_to_remove(true)
      expected_invalid_itter_policy = CPE::ChromeManagement::KnownSettings::GENERATED.fetch(
        'ExtensionInstallBlocklist', nil
)
      expected_invalid_flat_policy = CPE::ChromeManagement::KnownSettings::GENERATED.fetch(
        'TotalMemoryLimitMb', nil
)

      expect(doomed_policies).to have_key(expected_invalid_itter_policy)
      expect(doomed_policies).to have_key(expected_invalid_flat_policy)
      expect(doomed_policies.fetch(expected_invalid_flat_policy)).to eq(invalid_flat_setting)
      expect(doomed_policies.keys.length).to eq(2)
    end
    it 'removes managed settings that are not set' do
      fake_node = default_settings
      fake_node['cpe_chrome']['profile'] = {}
      invalid_itter_setting = [{ :name => '1', :type => :string, :data => 'modifiedextensionid' }]
      invalid_flat_setting = [{ :name => 'TotalMemoryLimitMb', :type => :dword, :data => 0 }]
      allow(wch).to receive(:registry_get_values).and_raise(Chef::Exceptions::Win32RegKeyMissing)
      allow(wch).to receive(:registry_get_values).with(
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist',
      ).and_return(invalid_itter_setting)

      allow(wch).to receive(:registry_get_values).with(
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome',
      ).and_return(invalid_flat_setting)

      wch.set_reg_settings(fake_node)

      doomed_policies = wch.policies_to_remove(true)
      expected_invalid_itter_policy = CPE::ChromeManagement::KnownSettings::GENERATED.fetch(
        'ExtensionInstallBlocklist', nil
)
      expected_invalid_flat_policy = CPE::ChromeManagement::KnownSettings::GENERATED.fetch(
        'TotalMemoryLimitMb', nil
)

      expect(doomed_policies).to have_key(expected_invalid_itter_policy)
      expect(doomed_policies).to have_key(expected_invalid_flat_policy)
      expect(doomed_policies.fetch(expected_invalid_flat_policy)).to eq(invalid_flat_setting)
      expect(doomed_policies.keys.length).to eq(2)
    end
  end

  context 'gen_reg_file_settings' do
    it 'generates policy map' do
      expected_settings = {
        :delete => {
          :flat => {
            'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome' => [
              { :name => 'TotalMemoryLimitMb', :type => :dword, :data => 0 },
            ],
          },
          :iterable => [
            'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist',
          ],
        },
        :create => {
          'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist' => [
            { :name => '1', :type => :string, :data => 'fake_extension_id' },
          ],
            'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome' => [
              { :name => 'TotalMemoryLimitMb', :type => :dword, :data => 512 },
            ],
        },
      }

      invalid_itter_setting = [{ :name => '1', :type => :string, :data => 'modifiedextensionid' }]
      invalid_flat_setting = [{ :name => 'TotalMemoryLimitMb', :type => :dword, :data => 0 }]
      allow(wch).to receive(:registry_get_values).and_raise(Chef::Exceptions::Win32RegKeyMissing)
      allow(wch).to receive(:registry_get_values).with(
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist',
      ).and_return(invalid_itter_setting)

      allow(wch).to receive(:registry_get_values).with(
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome',
      ).and_return(invalid_flat_setting)

      fake_node = default_settings
      new_settings = wch.set_reg_settings(fake_node)
      doomed_policies = wch.policies_to_remove(true)
      settings = wch.gen_reg_file_settings(doomed_policies, new_settings)
      expect(settings).to eq(expected_settings)
    end
  end
  context 'verify_update_needed' do
    it 'should return false when no policy is set to be deleted or created' do
      settings = { :delete => { :flat => {}, :iterable => [] }, :create => {} }
      expect(wch.verify_update_needed(settings)).to be false
    end
    it 'should return true when a policy is set to be deleted' do
      flat_settings = { :delete => { :flat => { 'path' => [{ :name => :foo }] } } }
      iter_settings = { :delete => { :iterable => ['foo'] } }

      expect(wch.verify_update_needed(flat_settings)).to be true
      expect(wch.verify_update_needed(iter_settings)).to be true
    end
    it 'should return true when a set policy registry key does not exist' do
      allow(wch).to receive(:registry_key_exists?).and_return(false)
      settings = {
        :delete => { :flat => {}, :iterable => [] },
        :create => {
          'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist' => [
            { :name => '1', :type => :string, :data => 'fake_extension_id' },
          ],
            'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome' => [
              { :name => 'TotalMemoryLimitMb', :type => :dword, :data => 512 },
            ],
        },
      }
      expect(wch.verify_update_needed(settings)).to be true
    end
  end
end
