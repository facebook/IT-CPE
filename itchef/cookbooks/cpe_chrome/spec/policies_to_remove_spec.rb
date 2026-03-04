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
# Spec:: policies_to_remove

require 'chefspec'
require_relative '../libraries/windows_chrome_settingv2'
require_relative '../libraries/gen_windows_chrome_known_settings'
require_relative '../libraries/chrome_windows'
require_relative '../libraries/windows_helpers'

describe CPE::WindowsChromeHelpers do
  let(:wch) { Class.new { extend CPE::WindowsChromeHelpers } }

  def default_settings
    {
      'cpe_chrome' => {
        'profile' => {
          'ExtensionInstallBlocklist' => ['fake_extension_id'],
        },
      },
    }
  end

  describe '#policies_to_remove' do
    context 'when iterable policy value is empty and registry key exists' do
      it 'marks the policy key for deletion and does not recreate it' do
        fake_node = default_settings
        fake_node['cpe_chrome']['profile']['ExtensionInstallBlocklist'] = []

        existing_registry_values = [
          { :name => '1', :type => :string, :data => 'old_extension_id' },
        ]

        allow(wch).to receive(:registry_get_values).and_raise(
          Chef::Exceptions::Win32RegKeyMissing,
        )
        allow(wch).to receive(:registry_get_values).with(
          'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist',
        ).and_return(existing_registry_values)

        reg_settings = wch.set_reg_settings(fake_node)
        doomed_policies = wch.policies_to_remove
        settings = wch.gen_reg_file_settings(doomed_policies, reg_settings)

        registry_location = 'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist'

        # Key should be marked for deletion
        expect(settings[:delete][:iterable]).to include(registry_location)

        # Key should NOT be recreated
        expect(settings[:create]).not_to have_key(registry_location)
      end
    end

    context 'when iterable policy value is nil and registry key exists' do
      it 'marks the policy key for deletion' do
        fake_node = default_settings
        fake_node['cpe_chrome']['profile']['ExtensionInstallBlocklist'] = nil

        existing_registry_values = [
          { :name => '1', :type => :string, :data => 'old_extension_id' },
        ]

        allow(wch).to receive(:registry_get_values).and_raise(
          Chef::Exceptions::Win32RegKeyMissing,
        )
        allow(wch).to receive(:registry_get_values).with(
          'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\ExtensionInstallBlocklist',
        ).and_return(existing_registry_values)

        wch.set_reg_settings(fake_node)

        doomed_policies = wch.policies_to_remove
        expected_iterable_policy = CPE::ChromeManagement::KnownSettings::GENERATED.fetch(
          'ExtensionInstallBlocklist', nil
        )

        expect(doomed_policies).to have_key(expected_iterable_policy)
        expect(doomed_policies.fetch(expected_iterable_policy)).to be_nil
      end
    end

    context 'when iterable policy registry key does not exist' do
      it 'does not mark the policy for deletion' do
        fake_node = default_settings
        fake_node['cpe_chrome']['profile']['ExtensionInstallBlocklist'] = []

        allow(wch).to receive(:registry_get_values).and_raise(
          Chef::Exceptions::Win32RegKeyMissing,
        )

        wch.set_reg_settings(fake_node)

        doomed_policies = wch.policies_to_remove

        expect(doomed_policies).to be_empty
      end
    end
  end
end
