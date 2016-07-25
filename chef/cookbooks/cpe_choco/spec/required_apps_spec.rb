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

describe 'cpe_choco::required_apps' do
  context 'outputs the list of apps' do
    let(:app_cache) do
      'C:\ProgramData\chocolatey\config\choco_req_apps.json'
    end
    let(:chocolatey_pkg) do
      {
        'name' => 'chocolatey',
        'version' => '0.9.10.2',
        'feed' => 'chocolatey',
      }
    end
    let(:rendered_chef_pkg_content) do
      /#{chocolatey_pkg.to_json}/
    end
    let(:file_resource) { chef_run.file(app_cache) }
    subject(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }
    it { should create_file(app_cache) }
    it { expect(file_resource.content).to match rendered_chef_pkg_content }
  end
end
