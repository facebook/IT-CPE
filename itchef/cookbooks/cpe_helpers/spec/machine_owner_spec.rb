# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chefspec'
require_relative '../libraries/cpe_helpers'
require_relative '../../cpe_logger/libraries/cpe_log'

describe CPE::Helpers do
  context 'When on Linux' do
    before do
      allow(CPE::Helpers).to receive(:macos?).and_return(false)
      allow(CPE::Helpers).to receive(:linux?).and_return(true)
      allow(CPE::Helpers).to receive(:windows?).and_return(false)
      allow(CPE::Log).to receive(:log)
    end

    context 'admin_groups' do
      it 'returns the right groups if the ID is unquoted' do
        allow(::File).to receive(:readlines).with('/etc/os-release').
          and_return(["ID=fedora\n"])
        expect(CPE::Helpers.admin_groups).to eq(['wheel'])
      end
      it 'returns the right groups if the ID is quoted' do
        allow(::File).to receive(:readlines).with('/etc/os-release').
          and_return(["ID=\"centos\"\n"])
        expect(CPE::Helpers.admin_groups).to eq(['wheel'])
      end
    end
  end

  context 'admin_users' do
    it 'handles non-existent groups' do
      allow(CPE::Helpers).to receive(:admin_groups).
        and_return(['admin', 'sudo'])
      allow(::Etc).to receive(:getgrnam).with('admin').
        and_raise(ArgumentError)
      allow(::Etc).to receive(:getgrnam).with('sudo').
        and_return(::Etc::Group.new('sudo', 'x', 10, ['alice', 'bob']))
      expect(CPE::Helpers.admin_users).to eq(['alice', 'bob'])
    end
  end

  context 'machine_owner' do
    before do
      allow(CPE::Helpers).to receive(:macos?).and_return(true)
      allow(CPE::Helpers).to receive(:linux?).and_return(false)
      allow(CPE::Helpers).to receive(:windows?).and_return(false)
      allow(CPE::Log).to receive(:log)
    end
    it 'filters out system UIDs and returns lowest user ID' do
      allow(CPE::Helpers).to receive(:admin_users).
        and_return(['root', 'bob', 'alice'])
      allow(::Etc).to receive(:getpwnam).with('root').
        and_return(::Etc::Passwd.new(
                     'root', '*', 0, 0, 'root', '/var/root', '/bin/sh'
        ))
      allow(::Etc).to receive(:getpwnam).with('bob').
        and_return(::Etc::Passwd.new(
                     'bob', '*', 501, 80, 'admin', '/Users/admin', '/bin/bash'
        ))
      allow(::Etc).to receive(:getpwnam).with('alice').
        and_return(::Etc::Passwd.new(
                     'alice', '*', 500, 80, 'alice', '/Users/alice', '/bin/bash'
        ))
      expect(CPE::Helpers.machine_owner).to eq('alice')
    end
    it 'filters out system UIDs and admin' do
      allow(CPE::Helpers).to receive(:admin_users).
        and_return(['root', 'admin', 'alice'])
      allow(::Etc).to receive(:getpwnam).with('root').
        and_return(::Etc::Passwd.new(
                     'root', '*', 0, 0, 'root', '/var/root', '/bin/sh'
        ))
      allow(::Etc).to receive(:getpwnam).with('admin').
        and_return(::Etc::Passwd.new(
                     'admin', '*', 501, 80, 'admin', '/Users/admin', '/bin/bash'
        ))
      allow(::Etc).to receive(:getpwnam).with('alice').
        and_return(::Etc::Passwd.new(
                     'alice', '*', 504, 80, 'alice', '/Users/alice', '/bin/bash'
        ))
      expect(CPE::Helpers.machine_owner).to eq('alice')
    end
  end
end
