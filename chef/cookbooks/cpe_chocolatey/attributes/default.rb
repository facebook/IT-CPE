#
# Cookbook Name:: cpe_chocolatey
# Attributes:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

# Choclatey directories and configurtions
default['cpe_chocolatey']['dir'] = ENV['ChocolateyInstall'].nil? ? \
            "#{ENV['PROGRAMDATA']}\\chocolatey" : ENV['ChocolateyInstall']
default['cpe_chocolatey']['config_dir'] = \
            "#{node['cpe_chocolatey']['dir']}\\config"
default['cpe_chocolatey']['config'] = \
            "#{node['cpe_chocolatey']['config_dir']}\\chocolatey.config"
default['cpe_chocolatey']['choco_run'] = \
            "#{node['cpe_chocolatey']['config_dir']}\\choco-run.ps1"
default['cpe_chocolatey']['app_cache'] = \
            "#{node['cpe_chocolatey']['config_dir']}\\choco_req_apps.json"

# Chocolatey Feeds
default['cpe_chocolatey']['default_feed'] = 'https://chocolatey.org/api/v2/'
