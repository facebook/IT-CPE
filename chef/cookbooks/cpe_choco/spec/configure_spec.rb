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
  let(:choco_dir) { 'C:\ProgramData\chocolatey' }
  let(:config_dir) { format('%s\config', choco_dir) }
  let(:config_path) { format('%s\chocolatey.config', config_dir) }
  let(:template_resource) { chef_run.template(config_path) }
end

describe 'CPE Managed Chocolatey Configuration' do
  context 'configures the chocolatey client with chef' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_configure']).
        converge('cpe_choco::default')
    end
    setup_cookbook_vars
    default_cookbook_checks
    it { should create_directory(choco_dir) }
    it { should create_directory(config_dir) }
    it { should create_template(config_path) }
  end
  context 'when given a blacklisted source the source is not present in' +
          'the configuration file' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_configure']) do |node|
        node.normal['cpe_choco']['source_blacklist'] = [
          'https://terrible.org/malicious/feed',
        ]
        node.normal['cpe_choco']['sources'] = {
          'bad_place' => {
            'source' => 'https://terrible.org/malicious/feed',
          },
          'good_place' => {
            'source' => 'https://awesome.org/coolandgood/feed',
          },
        }
      end.converge('cpe_choco::default')
    end
    setup_cookbook_vars
    it 'should not write bad_place to the config file' do
      should render_file(config_path).with_content(/good_place/)
      should_not render_file(config_path).with_content(/bad_place/)
    end
  end
  context 'when given multiple blacklisted sources there should only be one ' +
          'source rendered to the configuration file' do
    subject(:chef_run) do
      ChefSpec::SoloRunner.new(:step_into => ['cpe_choco_configure']) do |node|
        node.normal['cpe_choco']['source_blacklist'] = [
          'https://terrible.org/malicious/feed',
          'https://tatooine.com/cantina/feed',
          'https://not.sure.io/maybe/feed',
          'https://you.have.bad.taste.in/feeds',
        ]
        node.normal['cpe_choco']['sources'] = {
          'bad_place' => {
            'source' => 'https://terrible.org/malicious/feed',
          },
          'a_place_of_scum_and_villany' => {
            'source' => 'https://tatooine.com/cantina/feed',
          },
          'maybe_a_good_place' => {
            'source' => 'https://not.sure.io/maybe/feed',
          },
          'chocolatey' => {
            'source' => 'https://chocolatey.org/api/v2',
          },
          'nope' => {
            'source' => 'https://you.have.bad.taste.in/feeds',
          },
        }
      end.converge('cpe_choco::default')
    end
    setup_cookbook_vars
    it 'should not write bad places to the config file' do
      should render_file(config_path).with_content(/chocolatey/)
      should_not render_file(config_path).with_content(/bad_place/)
      should_not render_file(config_path).with_content(/maybe_a_good_place/)
      should_not render_file(config_path).with_content(/nope/)
      should_not render_file(config_path).
        with_content(/a_place_of_scum_and_villany/)
    end
  end
end
