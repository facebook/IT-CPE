#
# Cookbook Name:: cpe_chrome
# Recipe:: linux_chrome
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

return unless node.linux?

cpe_chrome 'Configure Google Chrome'

if node.fedora?

  yum_repository 'google-chrome' do
    description 'Google Chrome repo'
    baseurl 'http://dl.google.com/linux/chrome/rpm/stable/x86_64'
    enabled true
    gpgkey 'https://dl.google.com/linux/linux_signing_key.pub'
    gpgcheck true
    action :create
  end

  package 'google-chrome-stable' do
    action :upgrade
  end

end
