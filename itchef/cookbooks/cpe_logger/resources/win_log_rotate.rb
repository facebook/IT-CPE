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
# Resources:: win_log_rotate

unified_mode(false) if Chef::VERSION >= 18
default_action :rotate
provides :win_log_rotate

property :log_path, String
property :max_backups, Integer
property :day_interval, Integer

action_class do

end

action :rotate do
  log_path = new_resource.log_path

  return unless ::File.exist?(log_path)
  current_date = ::Date.today
  creation_date = ::File.ctime(log_path).to_date
  day_delta = (current_date - creation_date).to_i

  return unless ::File.exist?(log_path)
  return unless day_delta >= new_resource.day_interval
  converge_by("Rotating #{log_path}") do
    # Rotate old backups
    (new_resource.max_backups - 1).downto(0) do |i|
      cur_backup = "#{log_path}.#{i}"
      next unless ::File.exist?(cur_backup)
      new_backup = "#{log_path}.#{i+1}"
      ::FileUtils.mv(cur_backup, new_backup)
    end

    # rotate current log
    ::FileUtils.mv(log_path, "#{log_path}.0")
  end
end
