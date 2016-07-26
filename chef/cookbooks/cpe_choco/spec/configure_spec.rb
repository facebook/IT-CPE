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

def setup_cookbook_vars
  let(:choco_dir) { "#{ENV['PROGRAMDATA']}\\chocolatey" }
  let(:script) { format('%s\CPE\Chef\config\choco-run.ps1', ENV['WINDIR']) }
  let(:config_path) { "#{choco_dir}\\config\\chocolatey.config" }
  let(:blacklist_block_name) { 'blacklisted_items' }
  let(:blacklist_block) { chef_run.ruby_block(blacklist_block_name) }
  let(:template_resource) { chef_run.template(config_path) }
  let(:updater_task_opts) { { :action => [:create, :enable] } }
end

describe 'cpe_choco::configure' do
  context 'configures the chocolatey client with chef' do
    subject(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }
    setup_cookbook_vars
    it { should run_whyrun_safe_ruby_block(blacklist_block_name) }
    it { should create_template(config_path) }
    it { should create_cookbook_file(script) }
    it 'should create and enable the chocolatey updater task' do
      should create_windows_task('Chocolatey Updater').with(updater_task_opts)
    end
  end
end
