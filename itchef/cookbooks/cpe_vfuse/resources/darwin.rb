#
# Cookbook Name:: cpe_vfuse
# Resource:: default
#
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

resource_name :cpe_vfuse_darwin
provides :cpe_vfuse_darwin, :os => 'darwin'
default_action :manage

action :manage do
  install if node['cpe_vfuse']['install']
  templates unless node['cpe_vfuse']['templates'].empty?
end

action_class do
  def install
    pkg = node['cpe_vfuse']['pkg']
    cpe_remote_pkg pkg['name'] do
      version pkg['version']
      receipt pkg['receipt']
      checksum pkg['checksum']
      pkg_url pkg['pkg_url'] if pkg['pkg_url']
      pkg_name pkg['pkg_name'] if pkg['pkg_name']
    end
  end

  def templates
    templates = []
    template_dir = node['cpe_vfuse']['template_dir']
    templates_on_disk = ::Dir.glob("#{template_dir}/*.json")

    directory template_dir do
      only_if { node['cpe_vfuse']['install'] }
      owner 'root'
      group 'admin'
      mode '0755'
      action :create
    end

    node['cpe_vfuse']['templates'].each do |template|
      path = "#{template_dir}/#{template['output_name']}.json"
      templates << path
      file path do
        only_if { node['cpe_vfuse']['install'] }
        content Chef::JSONCompat.to_json_pretty(template)
        owner 'root'
        group 'admin'
        mode '0644'
        action :create
      end
    end

    (templates_on_disk - templates).each do |template|
      unless template.empty?
        file template do
          action :delete
        end
      end
    end
  end
end
