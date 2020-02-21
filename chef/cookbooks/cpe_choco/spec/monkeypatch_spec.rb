# Copyright (c) Facebook, Inc. and its affiliates.

require_relative 'spec_helper'
require_relative '../libraries/chocolatey_provider_monkeypatch'

describe Chef::Provider::Package::Chocolatey do
  context 'Guarding against possibility of version being nil object' do
    subject do
      described_class.new(double, double('node', :resource_collection => []))
    end
    it 'should account for a nil version because we know THAT is possible' do
      mock = double('choco_command', :stdout => 'derp|')
      allow(subject).to receive(:choco_command).with(anything).and_return(mock)

      # Yes, this violates the concept of private functions but ya know what?
      # IDGAF, this has caused enough pain to need to be tested.
      expect { subject.send(:parse_list_output, 'blah') }.to_not raise_error
      expect(subject.send(:parse_list_output, 'blah')).to eql({ 'derp' => nil })
    end
    it 'should parse the packages into a hash' do
      choco_list = <<-'EOF'
Chocolatey v0.10.3
chocolatey|0.10.3
chocolatey-core.extension|1.3.1
notepadplusplus|7.4.1
notepadplusplus.install|7.4.1
EOF
      expected = {
        'chocolatey' => '0.10.3',
        'chocolatey-core.extension' => '1.3.1',
        'notepadplusplus' => '7.4.1',
        'notepadplusplus.install' => '7.4.1',
      }
      mock = double('choco_command', :stdout => choco_list)
      allow(subject).to receive(:choco_command).with(anything).and_return(mock)
      expect(subject.send(:parse_list_output, 'blah')).to eql(expected)
    end
    it 'should return an empty hash if there are no packages' do
      choco_list = <<-'EOF'
Chocolatey v0.10.3
EOF
      mock = double('choco_command', :stdout => choco_list)
      allow(subject).to receive(:choco_command).with(anything).and_return(mock)
      expect(subject.send(:parse_list_output, 'blah')).to eql({})
    end
  end
end
