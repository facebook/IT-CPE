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

# Cookbook Name:: cpe_spotlight
# Recipe:: default

return unless node.macos?
# Abort if Spotlight indexing is disabled
spotlight_data =
  shell_out('/usr/bin/mdutil -s /').stdout

return if spotlight_data.include?('No index.') ||
          spotlight_data.include?('Spotlight server is disabled.')

cpe_spotlight 'Add Spotlight exclusions' do
  only_if { node['cpe_spotlight']['exclusions'].any? }
end

cpe_spotlight 'Clean up removed Spotlight exclusions' do
  action :clean_up
end
