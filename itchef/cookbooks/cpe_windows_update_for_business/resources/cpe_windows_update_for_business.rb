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
unified_mode(false) if Chef::VERSION >= 18
default_action :config

# rubocop:disable Layout/LineLength
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
         :default => lazy {
                       node['cpe_windows_update_for_business']['pause_quality_updates_start_time']
                     }

property :pause_feature_updates_start_time,
         [String, NilClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['pause_feature_updates_start_time']
                     }

property :exclude_wu_drivers_in_quality_update,
         [TrueClass, FalseClass, NilClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['exclude_wu_drivers_in_quality_update']
                     }

property :target_release_version,
         [TrueClass, FalseClass, NilClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['target_release_version']
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

property :product_version,
         [String, NilClass],
         :callbacks => {
           'must be a valid product' => lambda { |v|
             CPE::WindowsUpdateForBusiness::ProductVersion.valid?(v)
           },
         },
         :default => lazy {
           node['cpe_windows_update_for_business']['product_version']
         }

property :configure_deadline_for_quality_updates,
         [Integer, NilClass],
         :callbacks => {
           'is not between 0-30' => ->(v) { v.between?(0, 30) },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['configure_deadline_for_quality_updates']
                     }

property :configure_deadline_for_feature_updates,
         [Integer, NilClass],
         :callbacks => {
           'is not between 0-30' => ->(v) { v.between?(0, 30) },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['configure_deadline_for_feature_updates']
                     }

property :configure_deadline_grace_period_for_feature_updates,
         [Integer, NilClass],
         :callbacks => {
           'is not between 0-7' => ->(v) { v.between?(0, 7) },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['configure_deadline_grace_period_for_feature_updates']
                     }

property :configure_deadline_grace_period,
         [Integer, NilClass],
         :callbacks => {
           'is not between 0-7' => ->(v) { v.between?(0, 7) },
         },
         :default => lazy {
                       node['cpe_windows_update_for_business']['configure_deadline_grace_period']
                     }

property :set_compliance_deadline,
         [TrueClass, FalseClass, NilClass],
         :default => lazy {
                       node['cpe_windows_update_for_business']['set_compliance_deadline']
                     }

property :set_restart_warning_schedule,
         [TrueClass, FalseClass, NilClass],
         :default => lazy {
           node['cpe_windows_update_for_business']['set_restart_warning_schedule']
         }

property :configure_schedule_restart_warning,
         [Integer, NilClass],
         :callbacks => {
           'is not between 2 and 24' => ->(v) { v.between?(2, 24) },
         },
         :default => lazy {
           node['cpe_windows_update_for_business']['configure_schedule_restart_warning']
         }

property :configure_schedule_imminent_restart_warning,
         [Integer, NilClass],
         :callbacks => {
           'is not between 15 and 60' => ->(v) { v.between?(15, 60) },
         },
         :default => lazy {
           node['cpe_windows_update_for_business']['configure_schedule_imminent_restart_warning']
         }

property :set_auto_restart_required_notification_dismissal,
         [TrueClass, FalseClass, NilClass],
         :default => lazy {
           node['cpe_windows_update_for_business']['set_auto_restart_required_notification_dismissal']
         }

property :configure_auto_restart_required_notification_dismissal,
         [Integer, NilClass],
         :callbacks => {
           'is not between 1 and 2' => ->(v) { v.between?(1, 2) },
         },
         :default => lazy {
           node['cpe_windows_update_for_business']['configure_auto_restart_required_notification_dismissal']
         }

property :set_elevate_non_admins,
         [TrueClass, FalseClass, NilClass],
         :default => lazy {
           node['cpe_windows_update_for_business']['set_elevate_non_admins']
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
      use_compliance_deadlines = bool_from_int_or_nil(value.fetch('SetComplianceDeadline', 0))
      target_release_version_enabled = bool_from_int_or_nil(value.fetch('TargetReleaseVersion', 0))
      use_restart_warning_schedule = bool_from_int_or_nil(value.fetch('SetRestartWarningSchd', 0))
      require_notification_dismissal = bool_from_int_or_nil(value.fetch('SetAutoRestartRequiredNotificationDismissal', 0))
      non_admin = bool_from_int_or_nil(value.fetch('ElevateNonAdmins', 0))

      branch_readiness_level value.fetch('BranchReadinessLevel', nil)
      product_version value.fetch('ProductVersion', nil)
      defer_quality_updates_period_in_days value.fetch('DeferQualityUpdatesPeriodinDays', nil)
      defer_feature_updates_period_in_days value.fetch('DeferFeatureUpdatesPeriodinDays', nil)
      pause_quality_updates_start_time value.fetch('PauseQualityUpdatesStartTime', nil)
      pause_feature_updates_start_time value.fetch('PauseFeatureUpdatesStartTime', nil)
      target_release_version_info value.fetch('TargetReleaseVersionInfo', nil)
      target_release_version target_release_version_enabled
      exclude_wu_drivers_in_quality_update exclude_drivers
      defer_quality_updates defer_quality
      defer_feature_updates defer_feature
      configure_deadline_for_quality_updates value.fetch('ConfigureDeadlineForQualityUpdates', nil)
      configure_deadline_for_feature_updates value.fetch('ConfigureDeadlineForFeatureUpdates', nil)
      configure_deadline_grace_period_for_feature_updates value.fetch('ConfigureDeadlineGracePeriodForFeatureUpdates', nil)
      configure_deadline_grace_period value.fetch('ConfigureDeadlineGracePeriod', nil)
      set_restart_warning_schedule use_restart_warning_schedule
      configure_schedule_restart_warning value.fetch('ScheduleRestartWarning', nil)
      configure_schedule_imminent_restart_warning value.fetch('ScheduleImminentRestartWarning', nil)
      set_auto_restart_required_notification_dismissal require_notification_dismissal
      configure_auto_restart_required_notification_dismissal value.fetch('AutoRestartRequiredNotificationDismissal', nil)
      set_elevate_non_admins non_admin
      set_compliance_deadline use_compliance_deadlines
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
    :target_release_version => {
      'subkey' => 'TargetReleaseVersion',
      'only_if' => proc { node.os_at_least?('10.0.17134.0') },
    },
    :target_release_version_info => {
      'subkey' => 'TargetReleaseVersionInfo',
      'only_if' => proc { node.os_at_least?('10.0.17134.0') },
    },
    :product_version => {
      'subkey' => 'ProductVersion',
    },
    :configure_deadline_for_quality_updates => {
      'subkey' => 'ConfigureDeadlineForQualityUpdates',
    },
    :configure_deadline_for_feature_updates => {
      'subkey' => 'ConfigureDeadlineForFeatureUpdates',
    },
    :configure_deadline_grace_period_for_feature_updates => {
      'subkey' => 'ConfigureDeadlineGracePeriodForFeatureUpdates',
    },
    :configure_deadline_grace_period => {
      'subkey' => 'ConfigureDeadlineGracePeriod',
    },
    :set_compliance_deadline => {
      'subkey' => 'SetComplianceDeadline',
    },
    :set_restart_warning_schedule => {
      'subkey' => 'SetRestartWarningSchd',
    },
    :configure_schedule_restart_warning => {
      'subkey' => 'ScheduleRestartWarning',
    },
    :configure_schedule_imminent_restart_warning => {
      'subkey' => 'ScheduleImminentRestartWarning',
    },
    :set_auto_restart_required_notification_dismissal => {
      'subkey' => 'SetAutoRestartRequiredNotificationDismissal',
    },
    :configure_auto_restart_required_notification_dismissal => {
      'subkey' => 'AutoRestartRequiredNotificationDismissal',
    },
    :set_elevate_non_admins => {
      'subkey' => 'ElevateNonAdmins',
    },
  }.each do |k, v|
    converge_if_changed k do
      new_value = new_resource.send(k)
      reg_values = { v['subkey'] => new_value }

      # nil in this sense is "Not Configured" which means it doesn't exist
      # in the registry
      if new_value.nil?
        delete_list << create_registry_hash({ v['subkey'] => nil })
        next
      end

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
# rubocop:enable Layout/LineLength
