# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

require 'chefspec'
require_relative 'support/matchers'

RSpec.configure do |config|
  config.platform = 'windows'
  config.version  = '2012R2'
end

def default_cookbook_checks
  it 'should run our custom resources' do
    should bootstrap_cpe_choco('bootstrap if needed')
    should configure_cpe_choco('configuring chocolatey client')
    should manage_cpe_choco_apps('managing system applications')
  end
end

ChefSpec::Coverage.start!
