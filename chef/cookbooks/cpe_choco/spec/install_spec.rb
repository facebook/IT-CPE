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

def windows_runner_setup
  ChefSpec::SoloRunner.new do |node|
    node.automatic['platform'] = 'windows'
    node.automatic['platform_family'] = 'windows'
    node.set[:evaluate_guards] = true
    node.set[:actually_run_shell_guards] = true
  end.converge(described_recipe)
end

describe 'cpe_choco::install' do
  context 'the node is not a Windows operating system' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.automatic['platform_family'] = 'linux'
      end.converge(described_recipe)
    end
    it { should_not run_powershell_script('install_chocolatey') }
  end
  context 'the node is running the Windows operating system' do
    context 'chocolatey is not installed' do
      subject(:chef_run) { windows_runner_setup }
      before do
        stub_const('ENV', {})
      end
      it { should run_powershell_script('chocolatey_install') }
    end
    context 'chocolatey is installed' do
      subject(:chef_run) { windows_runner_setup }
      before do
        stub_const('ENV', {'ChocolateyInstall' => 'sure'})
      end
      it { should_not run_powershell_script('chocolatey_install') }
    end
  end
end
