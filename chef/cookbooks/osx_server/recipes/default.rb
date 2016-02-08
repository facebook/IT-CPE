# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_imaging_servers
# Recipe:: default
#
# Copyright 2014, Facebook CPE
#
# All rights reserved - Do Not Redistribute
#

return unless node.macosx?

# Configure service directories, account
include_recipe 'cpe_imaging_servers::setup'

# Configure and enable OS X Server.app services
include_recipe 'cpe_imaging_servers::osx_server'
