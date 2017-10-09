# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_adobe_flash
# Recipe:: default
#
# Copyright 2017, Facebook
#
# All rights reserved - Do Not Redistribute
#

return if node.linux?
cpe_adobe_flash 'Managing Adobe Flash'
