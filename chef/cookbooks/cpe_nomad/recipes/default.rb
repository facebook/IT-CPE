# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_nomad
# Recipe:: default
#
# Copyright 2017, Facebook CPE
#
# All rights reserved - Do Not Redistribute
#

return unless node.macos?

cpe_nomad_darwin 'Configure NoMAD'
