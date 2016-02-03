# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: remote_pkg
# Attributes:: default
#
# Copyright 2016-present, Facebook, CPE.
# All rights reserved - Do Not Redistribute
#

default['remote']['username'] = '' #chef_download_user
# I used this link to encode the password in URL:
# http://www.w3schools.com/tags/ref_urlencode.asp
default['remote']['pass'] = '' #P@$$w0rD
