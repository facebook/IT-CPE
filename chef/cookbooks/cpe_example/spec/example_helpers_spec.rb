# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

require 'chefspec'
require_relative '../libraries/example_helpers'
require_relative '../../cpe_utils/libraries/cpe_utils'

describe CPE::Example do
  let(:example) { Class.new { extend CPE::Example } }
  # This is where your spec tests go for your library functions.
  # There are lots of examples in IT Chef,but see D9982411 as a good example
  # of testing all of your libraries.

  # Some example spec tests for what to do on macOS vs. other platforms:
  context 'when on osx' do
    before do
      allow(CPE::Utils).to receive(:macos?).and_return(true)
    end
    # An example spec test for your library function
    it 'example_function should be' do
      expect(example.example_function).to eq(
        'this_is_the_return_value',
      )
    end
  end
end
