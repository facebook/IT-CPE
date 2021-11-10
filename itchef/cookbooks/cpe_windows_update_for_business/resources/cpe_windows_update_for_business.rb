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
# Resource:: cpe_windows_update_for_business

resource_name :cpe_windows_update_for_business
provides :cpe_windows_update_for_business
default_action :config

# rubocop:disable Metrics/LineLength
property :enabled,
         [TrueClass, FalseClass, NilClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['enabled']
                     }

property :branch_readiness_level,
         [Integer, NilClass],
         :callbacks => {
           'is not a valid branch: https://fburl.com/49rbm2aw' => lambda { |v|
             CPE::WindowsUpdateForBusiness::BranchReadinessLevel.valid?(v)
           },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['branch_readiness_level']
                     }

property :defer_quality_updates_period_in_days,
         [Integer, NilClass],
         :callbacks => {
           'is not between 0-35' => lambda { |v|
             v.nil? || v.between?(0, 35)
           },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['defer_quality_updates_period_in_days']
                     }

property :defer_feature_updates_period_in_days,
         [Integer, NilClass],
         :callbacks => {
           'is not between 0-365' => lambda { |v|
             v.nil? || v.between?(0, 365)
           },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['defer_feature_updates_period_in_days']
                     }

property :pause_quality_updates_start_time,
         [String, NilClass],
         :callbacks => {
           'is not in yyyy-mm-dd format' => lambda { |v|
             DateTime.parse(v).strftime('%Y-%m-%d') == v
           },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['pause_quality_updates_start_time']
                     }

property :pause_feature_updates_start_time,
         [String, NilClass],
         :callbacks => {
           'is not in yyyy-mm-dd format' => lambda { |v|
             DateTime.parse(v).strftime('%Y-%m-%d') == v
           },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['pause_feature_updates_start_time']
                     }

property :exclude_wu_drivers_in_quality_update,
         [TrueClass, FalseClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['exclude_wu_drivers_in_quality_update']
                     }

property :target_release_version_info,
         [String, NilClass],
         :callbacks => {
           'must be in https://aka.ms/ReleaseInformationPage' => lambda { |v|
             CPE::WindowsUpdateForBusiness::ReleaseInformation.valid?(v)
           },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['target_release_version_info']
                     }

property :defer_quality_updates,
         [TrueClass, FalseClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['defer_quality_updates']
                     }

property :defer_feature_updates,
         [TrueClass, FalseClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['defer_feature_updates']
                     }

property :use_wsus, [TrueClass, FalseClass], :default => false
property :au_set, [TrueClass, FalseClass], :default => false
property :managed_key_exists, [TrueClass, FalseClass], :default => true

action_class do
  include CPE::WindowsUpdateForBusiness
end

load_current_value do
  extend CPE::WindowsUpdateForBusiness

  managed_key_exists false

  load_current_registry_keys.each do |key, value|
    managed_key_exists true if key.end_with?('\\WUFBEnabled')

    if key.end_with?('\\AU')
      au_set registry_key_exists?(key) || value.any?
    else
      using_wsus = value.keys.any? { |k| k =~ /WU(Status)?Server/ }
      defer_quality = bool_from_int_or_nil(value.fetch('DeferQualityUpdates', 0))
      defer_feature = bool_from_int_or_nil(value.fetch('DeferFeatureUpdates', 0))
      exclude_drivers = bool_from_int_or_nil(value.fetch('ExcludeWUDriversInQualityUpdate', 0))

      branch_readiness_level value.fetch('BranchReadinessLevel', nil)
      defer_quality_updates_period_in_days value.fetch('DeferQualityUpdatesPeriodinDays', nil)
      defer_feature_updates_period_in_days value.fetch('DeferFeatureUpdatesPeriodinDays', nil)
      pause_quality_updates_start_time value.fetch('PauseQualityUpdatesStartTime', nil)
      pause_feature_updates_start_time value.fetch('PauseFeatureUpdatesStartTime', nil)
      target_release_version_info value.fetch('TargetReleaseVersionInfo', nil)
      exclude_wu_drivers_in_quality_update exclude_drivers
      defer_quality_updates defer_quality
      defer_feature_updates defer_feature
      use_wsus using_wsus
    end
  end
end

action :config do
  return if node['cpe_windows_update_for_business']['enabled'].nil?

  converge_if_changed :managed_key_exists do
    state_action = :create_if_missing
    if node['cpe_windows_update_for_business']['enabled'].is_a?(FalseClass)
      state_action = :delete_key
    end

    registry_key 'managed-registry-key-marker' do
      key "#{CPE::WindowsUpdateForBusiness::KEY_PATH}\\WUFBEnabled"
      recursive true
      action state_action
    end

    if node['cpe_windows_update_for_business']['enabled'].is_a?(FalseClass)
      # If we're not actually told to manage these policies delete this key and
      # then return early.
      return
    end
  end

  delete_list = []
  create_list = []

  converge_if_changed :au_set do
    registry_key 'delete-internal-automatic-update' do
      key "#{CPE::WindowsUpdateForBusiness::KEY_PATH}\\AU"
      recursive true
      action :delete_key
    end
  end

  converge_if_changed :use_wsus do
    delete_list << create_registry_hash(
      {
        'WUServer' => nil,
        'WUStatusServer' => nil,
      },
    )
  end

  {
    :branch_readiness_level => {
      'subkey' => 'BranchReadinessLevel',
    },
    :defer_quality_updates_period_in_days => {
      'subkey' => 'DeferQualityUpdatesPeriodinDays',
    },
    :defer_feature_updates_period_in_days => {
      'subkey' => 'DeferFeatureUpdatesPeriodinDays',
    },
    :pause_quality_updates_start_time => {
      'subkey' => 'PauseQualityUpdatesStartTime',
    },
    :pause_feature_updates_start_time => {
      'subkey' => 'PauseFeatureUpdatesStartTime',
    },
    :defer_feature_updates => {
      'subkey' => 'DeferFeatureUpdates',
    },
    :defer_quality_updates => {
      'subkey' => 'DeferQualityUpdates',
    },
    :exclude_wu_drivers_in_quality_update => {
      'subkey' => 'ExcludeWUDriversinQualityUpdate',
    },
    :target_release_version_info => {
      'subkey' => 'TargetReleaseVersionInfo',
      'only_if' => proc { node.os_at_least?('10.0.17134.0') },
    },
  }.each do |k, v|
    converge_if_changed k do
      new_value = new_resource.send(k)
      reg_values = { v['subkey'] => new_value }

      if v['only_if']
        if v['only_if'].call
          create_list << create_registry_hash(reg_values)
        end
      else
        create_list << create_registry_hash(reg_values)
      end
    end
  end

  unless create_list.empty?
    registry_key 'set-windows-update-for-business-keys' do
      key CPE::WindowsUpdateForBusiness::KEY_PATH
      values create_list.flatten
      recursive true
      action :create
    end
  end

  unless delete_list.empty?
    registry_key 'remove-windows-update-for-business-keys' do
      key CPE::WindowsUpdateForBusiness::KEY_PATH
      values delete_list.flatten
      recursive true
      action :delete
    end
  end
end
# rubocop:enable Metrics/LineLength
