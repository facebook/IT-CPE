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
# Resource:: cpe_pathsd_darwin

resource_name :cpe_pathsd_darwin
provides :cpe_pathsd, :os => 'darwin'
default_action :manage

action :manage do
  directory '/etc/paths.d/' do
    owner 'root'
    group 'wheel'
    mode 0755
  end

  template '/etc/paths.d/cpe_pathsd' do
    source 'cpe_pathsd'
    owner 'root'
    group 'wheel'
    mode 0644
  end
end
