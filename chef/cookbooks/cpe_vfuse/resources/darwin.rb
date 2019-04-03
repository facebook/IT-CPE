# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_vfuse
# Resources:: darwin
#
# Copyright (c) 2018-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
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
