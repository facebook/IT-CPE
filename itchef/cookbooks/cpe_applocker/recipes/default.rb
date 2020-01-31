# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_applocker
# Recipe:: default
#
# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

return unless node.windows?

cpe_applocker 'Uninstall Applocker' do
  not_if { node['cpe_applocker']['enabled'].nil? }
  not_if { node['cpe_applocker']['enabled'] }
  applocker_rules lazy { node['cpe_applocker']['applocker_rules'] }
  action :uninstall
end

cpe_applocker 'Install and configure Applocker' do
  # Lazily loaded so other cookbooks can override Applocker rules.
  only_if { node['cpe_applocker']['enabled'] }
  applocker_rules lazy { node['cpe_applocker']['applocker_rules'] }
  action :configure
end
