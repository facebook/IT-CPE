require 'rspec'
require 'chef/http/simple'
require_relative '../libraries/helpers'
require_relative '../../cpe_utils/libraries/cpe_distro'

describe CPE::Remote do
  let(:remote) { Class.new { extend CPE::Remote } }
  context 'valid_url?' do
    before do
      allow(CPE::Distro).to receive('auth_headers').and_return({})
    end

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
