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
      allow(CPE::Helpers).to receive(:machine_owner).
        and_return('from_machine_owner')
      allow(::File).to receive(:exist?).with('/usr/bin/loginctl').
        and_return(true)
      allow(::File).to receive(:exist?).with('/bin/loginctl').
        and_return(false)
    end

    context 'When loginctl does not exist' do
      before do
        CPE::Helpers.instance_variable_set :@console_user, nil
        CPE::Helpers.instance_variable_set :@loginctl_users, nil
        allow(::File).to receive(:exist?).with('/usr/bin/loginctl').
          and_return(false)
      end
      it 'console_user returns machine owner' do
        expect(CPE::Helpers.console_user).to eq('from_machine_owner')
      end
    end

    context 'When loginctl returns no end-user' do
      context 'When shell_out fails' do
        before do
          CPE::Helpers.instance_variable_set :@console_user, nil
          CPE::Helpers.instance_variable_set :@loginctl_users, nil
          allow(CPE::Helpers).to receive(:shell_out).
            with('/usr/bin/loginctl --no-legend list-users').and_return(
              double(
                :error? => true,
              ),
            )
        end
        it 'loginctl_users should return []' do
          expect(CPE::Helpers.loginctl_users).to eq([])
        end

        it 'console_user should return machine owner' do
          expect(CPE::Helpers.console_user).to eq('from_machine_owner')
        end
      end

      context 'When shell_out returns only gdm' do
        before do
          CPE::Helpers.instance_variable_set :@console_user, nil
          CPE::Helpers.instance_variable_set :@loginctl_users, nil
          allow(CPE::Helpers).to receive(:shell_out).
            with('/usr/bin/loginctl --no-legend list-users').and_return(
              double(
                :error? => false,
                :stdout => " 42 gdm \n",
              ),
            )
        end

        it 'loginctl_users should return a list with gdm' do
          expect(CPE::Helpers.loginctl_users).to eq(
            [{ 'uid' => 42, 'user' => 'gdm' }],
          )
        end

        it 'console_user should return machine owner' do
          expect(CPE::Helpers.console_user).to eq('from_machine_owner')
        end
      end

      context 'When shell_out returns only an end user' do
        before do
          CPE::Helpers.instance_variable_set :@console_user, nil
          CPE::Helpers.instance_variable_set :@loginctl_users, nil
          allow(CPE::Helpers).to receive(:shell_out).
            with('/usr/bin/loginctl --no-legend list-users').and_return(
              double(
                :error? => false,
                :stdout => "1001 endusr\n",
              ),
            )
        end

        it 'loginctl_users should return a list with endusr' do
          expect(CPE::Helpers.loginctl_users).to eq(
            [{ 'uid' => 1001, 'user' => 'endusr' }],
          )
        end

        it 'console_user should return endusr' do
          expect(CPE::Helpers.console_user).to eq('endusr')
        end
      end

      context 'When shell_out returns gdm and an end user' do
        before do
          CPE::Helpers.instance_variable_set :@console_user, nil
          CPE::Helpers.instance_variable_set :@loginctl_users, nil
          allow(CPE::Helpers).to receive(:shell_out).
            with('/usr/bin/loginctl --no-legend list-users').and_return(
              double(
                :error? => false,
                :stdout =>
                  "      1001 endusr          \n" +
                  "        42 gdm             \n",
              ),
            )
        end

        it 'loginctl_users should return a list with gdm and endusr' do
          require 'set'
          expect(CPE::Helpers.loginctl_users.to_set).to eq(
            [{ 'uid' => 42, 'user' => 'gdm' },
             { 'uid' => 1001, 'user' => 'endusr' }].to_set,
          )
        end

        it 'console_user should return endusr' do
          expect(CPE::Helpers.console_user).to eq('endusr')
        end
      end
    end
  end

  context 'When on Windows' do
    context '#logged_on_user_query' do
      subject { CPE::Helpers }

      NO_USER = <<-'EOF'.freeze
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
        EOF
      ONE_USER = <<-'EOF'.freeze
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
>testdummy             console             1  Active      none   8/31/2020 12:22 PM
        EOF
      TWO_USERS = <<-'EOF'.freeze
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
testdummy              console             1  Active      none   8/31/2020 12:22 PM
testdummy2             console             1  Active      none   8/31/2020 18:00 PM
        EOF
      INACTIVE_USERS = <<-'EOF'.freeze
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
testdummy              console             1  Inactive    none   8/31/2020 12:22 PM
testdummy2             console             1  Active      none   8/31/2020 18:00 PM
        EOF

      MISSING_FIELD = <<-'EOF'.freeze
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
testdummy              console             1
        EOF

      before do
        allow(Chef::Log).to receive(:debug)
      end

      it 'should return nil if there is an exception' do
        allow(subject).to receive(:shell_out).and_raise(NoMethodError, 'aieee')
        expect(subject.logged_on_user_query).to be nil
      end

      it 'should return nil if the command output is empty' do
        result = double(:stdout => '')
        allow(subject).to receive(:shell_out).and_return(result)
        expect(subject.logged_on_user_query).to be nil
      end

      it 'should return nil if the output does not contain a user' do
        result = double(:stdout => NO_USER)
        allow(subject).to receive(:shell_out).and_return(result)
        expect(subject.logged_on_user_query).to be nil
      end

      it 'should return nil if the command times out' do
        allow(subject).to receive(:shell_out).and_raise(
          Mixlib::ShellOut::CommandTimeout,
        )
        allow(Chef::Log).to receive(:warn)
        expect(Chef::Log).to receive(:warn).
          with('command timeout while looking up user').
          once
        expect(subject.logged_on_user_query).to be nil
      end

      it 'should return nil if a field is missing for whatever reason' do
        result = double(:stdout => MISSING_FIELD)
        allow(subject).to receive(:shell_out).and_return(result)
        expect(subject.logged_on_user_query).to be nil
      end

      {
        'should return testdummy' =>
          { 'output' => ONE_USER, 'expected' => 'testdummy' },
        'should return testdummy when two users are present' =>
          { 'output' => TWO_USERS, 'expected' => 'testdummy' },
        'should return testdummy2 when testdummy is inactive' =>
          { 'output' => INACTIVE_USERS, 'expected' => 'testdummy2' },
      }.each do |test_name, test_data|
        it test_name do
          result = double(:stdout => test_data['output'])
          allow(subject).to receive(:shell_out).and_return(result)
          expect(subject.logged_on_user_query).to eql test_data['expected']
        end
      end
    end
  end
end
