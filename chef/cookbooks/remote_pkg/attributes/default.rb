#
# Cookbook Name:: remote_pkg
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

default['remote']['username'] = nil #chef_download_user
# I used this link to encode the password in URL:
# http://www.w3schools.com/tags/ref_urlencode.asp
default['remote']['pass'] = nil #P@$$w0rD
# Put there server and path of you pkgs
default['remote_pkg']['server'] = PUT YOUR SERVER HERE
