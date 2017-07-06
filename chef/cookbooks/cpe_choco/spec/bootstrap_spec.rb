# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#
# rubocop:disable Metrics/BlockLength
require_relative 'spec_helper'

def windows_runner_setup(choco_desired = '0.0.0')
  ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_bootstrap']) do |node|
    node.automatic['platform'] = 'windows'
    node.automatic['platform_family'] = 'windows'
    node.default[:evaluate_guards] = true
    node.default[:actually_run_shell_guards] = true
    node.normal['cpe_choco']['bootstrap']['version'] = choco_desired
  end.converge('cpe_choco::default')
end

describe 'CPE Managed Chocolatey Bootstrapper' do
  context 'the node is not a Windows operating system' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_bootstrap']) do |node|
        node.automatic['platform_family'] = 'linux'
      end.converge('cpe_choco::default')
    end
    default_cookbook_checks
    it { should_not run_powershell_script('install_chocolatey') }
  end
  context 'the node is running the Windows operating system' do
    context 'chocolatey is not installed' do
      subject(:chef_run) { windows_runner_setup }
      default_cookbook_checks
      it 'should install chocolatey if it is not installed' do
        stub_const('ENV', {})
        allow(File).to receive(:file?).and_call_original
        allow(File).to receive(:file?).
          with('C:\ProgramData\chocolatey\choco.exe').and_return(false)

        should create_cookbook_file('chocolatey bootstrap file')
        should run_powershell_script('chocolatey_install')
      end
    end
    context 'chocolatey is installed' do
      subject(:chef_run) { windows_runner_setup('0.10.3') }
      default_cookbook_checks
      before do
        stub_const('ENV', { 'ChocolateyInstall' => 'sure' })
        allow(File).to receive(:file?).and_call_original
        allow(File).to receive(:file?).
          with('C:\ProgramData\chocolatey\choco.exe').and_return(true)
      end
      it 'should not install chocolatey if it is already installed and the' +
         'desired version is the same' do
        allow_any_instance_of(Mixlib::ShellOut).to \
          receive_message_chain('run_command.stdout').and_return('0.10.3')

        should create_cookbook_file('chocolatey bootstrap file')
        should_not run_powershell_script('chocolatey_install')
        should_not run_powershell_script('upgrade_choco')
      end
      it 'should not install chocolatey if it is already installed but ' +
         'upgrade to the desired version' do
        allow_any_instance_of(Mixlib::ShellOut).to \
          receive_message_chain('run_command.stdout').and_return('0.10.2')

        should create_cookbook_file('chocolatey bootstrap file')
        should_not run_powershell_script('chocolatey_install')
        should run_powershell_script('upgrade_choco')
      end
    end
  end
end
