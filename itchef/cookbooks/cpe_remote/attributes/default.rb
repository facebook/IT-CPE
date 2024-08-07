# Cookbook Name:: cpe_remote
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

default['cpe_remote'] = {
  'base_url' => 'MY DISTRO SERVER/chef',
  'server_accessible' => true,
  'additional_headers' => {},
  'force_cpe_distro' => false,
}
