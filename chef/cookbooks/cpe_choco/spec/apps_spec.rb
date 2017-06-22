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

describe 'CPE Managed Chocolatey Applications' do
  let(:installs) do
    {
      'chocolatey' => {
        'version' => '0.9.10.3', # provider coerces to array for some reason??
        'source' => 'https://chocolatey.org/api/v2',
      },
      'firefox' => {
        'version' => 'latest',
      },
      'git' => {
        'version' => '2.9.0',
      },
    }
  end
  let(:removals) do
    {
      'h4xx' => {
        'version' => '1337',
      },
      'git' => {
        'version' => '12.0.1',
      },
    }
  end
  context 'Installs or upgrades a list of applications given an array of ' +
          'key/value pairs' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_apps']) do |node|
        node.normal['cpe_choco']['install'] = installs
        node.normal['cpe_choco']['uninstall'] = {}
      end.converge('cpe_choco::default')
    end
    default_cookbook_checks
    it 'should install chocolatey with specified version given source' do
      test_choco_data = installs['chocolatey']
      expect(chef_run).to install_chocolatey_package('chocolatey').with(
        :version => [test_choco_data['version']],
        :source => test_choco_data['source'],
      )
    end
    it 'should upgrade firefox, install git, and not install h4xx' do
      should upgrade_chocolatey_package('firefox')
      should install_chocolatey_package('git')
      should_not install_chocolatey_package('h4xx')
    end
  end

  context 'Removes application from an array given the package name' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_apps']) do |node|
        node.normal['cpe_choco']['install'] = installs
        node.normal['cpe_choco']['uninstall'] = removals
      end.converge('cpe_choco::default')
    end
    it 'should remove git and h4xx, upgrade firefox, and install chocolatey' do
      should install_chocolatey_package('chocolatey')
      should upgrade_chocolatey_package('firefox')
      should remove_chocolatey_package('git')
      should remove_chocolatey_package('h4xx')
    end
  end

  context 'Specify specific options for removal' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_apps']) do |node|
        node.normal['cpe_choco']['install'] = {}
        node.normal['cpe_choco']['uninstall'] = {
          'h4xx' => {
            'version' => '1.2.3',
            'timeout' => 30,
            'retries' => 3,
            'options' => 'blah',
            'source' => 'derp',
          }
        }
      end.converge('cpe_choco::default')
    end
    it 'should remove a package with given options' do
      should remove_chocolatey_package('h4xx').with(
        :timeout => 30,
        :retries => 3,
        :options => 'blah',
        :source => 'derp',
      )
    end
  end

  context 'During an install the last installation takes precedence' do
    let(:precedence_check) do
      # This needs to be disabled temporarily to test proper behavior.
      # rubocop:disable Lint/DuplicatedKey
      {
        'chocolatey' => {
          'version' => '0.9.10.3',
        },
        'chocolatey' => {
          'version' => 'latest',
        },
      }
      # rubocop:enable Lint/DuplicatedKey
    end
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_apps']) do |node|
        node.normal['cpe_choco']['install'] = precedence_check
        node.normal['cpe_choco']['uninstall'] = {}
      end.converge('cpe_choco::default')
    end
    it 'should upgrade chocolatey since the upgrade is last in the list' do
      expect(chef_run).to upgrade_chocolatey_package('chocolatey')
    end
  end

  context 'Given the same application install and a removal, the removal ' +
          'takes precedence over the install' do
    let(:installs) do
      {
        'h4xx' => {
          'version' => '1337',
        },
        'facebook' => {
          'version' => 'latest',
        },
      }
    end
    let(:removals) do
      {
        'h4xx' => {
          'version' => 'any',
        },
      }
    end
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_apps']) do |node|
        node.normal['cpe_choco']['install'] = installs
        node.normal['cpe_choco']['uninstall'] = removals
      end.converge('cpe_choco::default')
    end
    it 'should upgrade facebook and not install h4xx since the package is ' +
       'being removed' do
      expect(chef_run).not_to install_chocolatey_package('h4xx')
      expect(chef_run).to upgrade_chocolatey_package('facebook')
    end
  end

  context 'Given no version, an exception should be raised' do
    let(:installs) do
      {
        'h4xx' => {},
      }
    end
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_apps']) do |node|
        node.normal['cpe_choco']['install'] = installs
      end.converge('cpe_choco::default')
    end
    it 'should raise an exception when not provided a version' do
      expect { chef_run }.to \
        raise_error(::Chef::Exceptions::InvalidVersionConstraint)
    end
  end
  context 'Given no version, an exception should be raised' do
    let(:installs) do
      {
        'h4xx' =>  ['version', '1337'],
      }
    end
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_apps']) do |node|
        node.normal['cpe_choco']['install'] = installs
      end.converge('cpe_choco::default')
    end
    it 'should raise an exception when not passed as a key/value pair' do
      expect { chef_run }.to \
        raise_error(::Chef::Exceptions::InvalidResourceReference)
    end
  end
end
