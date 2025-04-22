# (c) Meta Platforms, Inc. and its affiliates. Confidential and proprietary.
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
# Cookbook Name:: cpe_logger
# Recipe:: windows_rotation

return unless node.windows?

win_log_rotate 'Rotate cpe_logger.log' do
  log_path CPE::Log.log_path
  max_backups 10
  day_interval 1
  only_if { node['cpe_logger']['enable_windows_rotation'] }
end
