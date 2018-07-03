# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_office
# Recipe:: default
#
# Copyright 2017, Facebook
#
# All rights reserved - Do Not Redistribute
return unless node.macos?
include_recipe "cpe_office::#{node['os']}_office"
