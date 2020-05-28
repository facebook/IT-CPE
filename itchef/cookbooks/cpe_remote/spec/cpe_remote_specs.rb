# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rspec'
require 'chef/http/simple'
require_relative '../libraries/helpers'
require_relative '../../cpe_helpers/libraries/cpe_helpers'

describe CPE::Remote do
  let(:remote) { Class.new { extend CPE::Remote } }
  context 'valid_url?' do
    url = 'https://cpespace.thefacebook.com/chef/test/test.pkg'
    [
      nil,
      false,
    ].each do |return_value|
      return_value_string = return_value.nil? ? 'nil' : return_value
      context "With return value: #{return_value_string}" do
        it 'Should return true' do
          allow(Chef::HTTP::Simple).
            to receive_message_chain(:new, :head).and_return(return_value)
          expect(remote.valid_url?(url)).to eq(true)
        end
      end
    end
    context 'When expection is raised' do
      it 'should return false' do
        allow(Chef::HTTP::Simple).
          to receive_message_chain(:new, :head).and_raise('boom')
        expect(remote.valid_url?(url)).to eq(false)
      end
    end
  end
end
