# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_applocker
# Attributes:: default
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

# Default state is that everything is in AuditOnly to generate logs. To enable
# set the `mode` variable to be `Enabled`
default['cpe_applocker'] = {
  # A ternary value which can be specified as follows:
  #
  # Enabled => true   The service is enabled and rulesets configured
  # Enabled => false  The service is disabled, rules are not configured
  # Enabled => nil    The service is not configured, no actions are taken
  'enabled' => nil,

  'applocker_rules' => {
    'Appx' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
    'Dll' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
    'Exe' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
    'Msi' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
    'Script' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
  },
}
