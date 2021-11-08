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
# Attributes:: default

default['cpe_windows_update_for_business'] = {
  'enabled' => nil,
  'product_version' => nil,
  'branch_readiness_level' => nil,
  'defer_quality_updates' => false,
  'defer_feature_updates' => false,
  'pause_feature_updates_start_time' => nil,
  'pause_quality_updates_start_time' => nil,
  'defer_quality_updates_period_in_days' => nil,
  'defer_feature_updates_period_in_days' => nil,
  'set_compliance_deadline' => nil,
  'configure_deadline_for_quality_updates' => nil,
  'configure_deadline_for_feature_updates' => nil,
  'configure_deadline_grace_period' => nil,
  'configure_deadline_grace_period_for_feature_updates' => nil,
  'exclude_wu_drivers_in_quality_update' => true,
  'target_release_version_info' => nil,
}
