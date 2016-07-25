# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

require_relative 'spec_helper'

describe 'cpe_choco::default' do
  context 'when the default cookbook runs' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }
    subject { chef_run }
    it { should include_recipe('cpe_choco::install') }
    it { should include_recipe('cpe_choco::configure') }
    it { should include_recipe('cpe_choco::required_apps') }
  end
end
