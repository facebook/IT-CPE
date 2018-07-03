# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_office
# Recipe:: darwin_office
#
# Copyright 2017, Facebook
#
# All rights reserved - Do Not Redistribute

return unless node.macos?
cpe_office_darwin 'Configure Microsoft Office'
