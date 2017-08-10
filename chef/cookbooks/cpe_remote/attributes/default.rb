# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_remote
# Attributes:: default
#
# Copyright 2014-present, Facebook, CPE.
# All rights reserved - Do Not Redistribute
#

default['cpe_remote'] = {
  'base_url' => 'MY DISTRO SERVER/chef',
  'server_accessible' => true,
}
