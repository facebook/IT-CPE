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

# Cookbook Name:: cpe_pathsd
# Resource:: cpe_pathsd_linux

resource_name :cpe_pathsd_linux
provides :cpe_pathsd, :os => 'linux'
default_action :manage

action :manage do
  directory '/etc/profile.d' do
    owner 'root'
    group 'root'
    mode '0755'
  end

  template '/etc/profile.d/cpe_paths.sh' do
    source 'profile.d_paths.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end
end
