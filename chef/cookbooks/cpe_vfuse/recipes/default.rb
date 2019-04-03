# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_vfuse
# Recipe:: default
#
# Copyright 2018, Facebook CPE
#
# All rights reserved - Do Not Redistribute
#

return unless node.macos?

cpe_vfuse_darwin 'Configure vfuse'
