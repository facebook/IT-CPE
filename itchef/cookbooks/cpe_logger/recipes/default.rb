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
#
# Cookbook Name:: cpe_logger
# Recipes:: default

if node.windows?
  include_recipe 'cpe_logger::windows_rotation'
else
  logfile = '/var/log/cpe_logger.log'
  logrotate_conf = if node.macos?
                     '/etc/newsyslog.d/cpe_logger.conf'
                   elsif node.linux?
                     '/etc/logrotate.d/cpe_logger.conf'
                   end

  return if logrotate_conf.nil?

  package 'logrotate' do
    only_if { node['cpe_logger']['enable'] }
    only_if { node.linux? }
    action :upgrade
  end

  template logrotate_conf do
    only_if { node['cpe_logger']['enable'] }
    source "logrotate.#{node['os']}.erb"
    owner node.root_user
    group node.root_group
    mode '0644'
    variables(
      :logfile => logfile,
    )
  end
end
