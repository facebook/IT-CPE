# Copyright (c) Facebook, Inc. and its affiliates.
#
require 'chefspec'
require_relative '../libraries/cpe_helpers'

describe CPE::Helpers do
  context 'When parsing RAM sizes' do
    expected = 8 * 1024 * 1024

    it 'parse_ram parses {X} GB correctly' do
      expect(CPE::Helpers.parse_ram('8 GB')).to eq(expected)
    end

    it 'parse_ram parses {X}GB correctly' do
      expect(CPE::Helpers.parse_ram('8GB')).to eq(expected)
    end

    it 'parse_ram parses {X} MB correctly' do
      expect(CPE::Helpers.parse_ram('8192 MB')).to eq(expected)
    end

    it 'parse_ram parses {X}MB correctly' do
      expect(CPE::Helpers.parse_ram('8192MB')).to eq(expected)
    end

    it 'parse_ram parses {X} KB correctly' do
      expect(CPE::Helpers.parse_ram('8388608 KB')).to eq(expected)
    end

    it 'parse_ram parses {X}KB correctly' do
      expect(CPE::Helpers.parse_ram('8388608KB')).to eq(expected)
    end
  end

  context 'When summing up RAM sizes' do
    let(:node) { Chef::Node.new }
    let(:dmi) { {} }
    let(:mem) { {} }

    before do
      allow(node).to receive(:[]).with('dmi').and_return(dmi)
      allow(node).to receive(:[]).with('memory').and_return(mem)
    end

    it 'sums up new dmidecode GB sizes correctly' do
      allow(dmi).to receive(:dig).with('memory_device', 'all_records').
        and_return([{ 'Size' => '16 GB' }, { 'Size' => '16 GB' }])
      expect(CPE::Helpers.dmi_ram_total(node)).to eq(32 * 1024 * 1024)
    end

    it 'sums up old dmidecode MB sizes correctly' do
      allow(dmi).to receive(:dig).with('memory_device', 'all_records').
        and_return([{ 'Size' => '8192 MB' }, { 'Size' => '8192 MB' }])
      expect(CPE::Helpers.dmi_ram_total(node)).to eq(16 * 1024 * 1024)
    end

    it 'falls back to meminfo if DMI data is unavailable' do
      allow(dmi).to receive(:dig).with('memory_device', 'all_records').
        and_return(nil)
      allow(mem).to receive(:dig).with('total').
        and_return('8388608kB')
      expect(CPE::Helpers.dmi_ram_total(node)).to eq(8 * 1024 * 1024)
    end
  end
end
