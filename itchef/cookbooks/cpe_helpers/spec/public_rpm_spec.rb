# Copyright (c) Facebook, Inc. and its affiliates.
#
require 'chefspec'
require_relative '../libraries/cpe_helpers'

describe CPE::Helpers do
  context 'When looking up an uninstalled package' do
    before do
      allow(CPE::Helpers).to receive(:shell_out).and_return(
        double(
          :error? => true,
          :stdout => 'package foobar is not installed\n',
        ),
      )
    end
    it 'rpm_installed? returns false on a versionless match' do
      expect(CPE::Helpers.rpm_installed?('foobar')).
        to eq(false)
    end
    it 'rpm_installed? returns false when given VR' do
      expect(CPE::Helpers.rpm_installed?('foobar', '1.0-1.fc29')).
        to eq(false)
    end
    it 'rpm_installed? returns false when given EVR' do
      expect(CPE::Helpers.rpm_installed?('foobar', '1:1.0-1.fc29')).
        to eq(false)
    end
    it 'rpm_installed? returns false when given VR, epoch on' do
      expect(CPE::Helpers.rpm_installed?('foobar', '1.0-1.fc29', true)).
        to eq(false)
    end
    it 'rpm_installed? returns false when given EVR, epoch on' do
      expect(CPE::Helpers.rpm_installed?('foobar', '1:1.0-1.fc29', true)).
        to eq(false)
    end
  end

  context 'When looking up an installed epoched package' do
    epoch = 2
    ver = '20181008_160002_e326bd0c3c21'
    rel = '1.acme.fc27'

    before do
      allow(CPE::Helpers).to receive(:shell_out).and_return(
        double(
          :error? => false,
          :stdout => "#{epoch}:#{ver}-#{rel}",
        ),
      )
    end
    it 'rpm_installed? returns true on a versionless match' do
      expect(CPE::Helpers.rpm_installed?('acme-tnt')).
        to eq(true)
    end
    it 'rpm_installed? returns true with matching VR, epoch off' do
      expect(CPE::Helpers.rpm_installed?(
               'acme-tnt', "#{ver}-#{rel}"
      )).to eq(true)
    end
    it 'rpm_installed? returns false with matching VR, epoch on' do
      expect(CPE::Helpers.rpm_installed?(
               'acme-tnt', "#{ver}-#{rel}", true
      )).to eq(false)
    end
    it 'rpm_installed? returns true with matching EVR, epoch on' do
      expect(CPE::Helpers.rpm_installed?(
               'acme-tnt', "#{epoch}:#{ver}-#{rel}", true
      )).to eq(true)
    end
    it 'rpm_installed? returns true with unmatched VR, epoch off' do
      expect(CPE::Helpers.rpm_installed?(
               'acme-tnt', '20180628_115900_cf99325oie-1.acme.fc27'
      )).to eq(false)
    end
    it 'rpm_installed? returns false with unmatched VR, epoch on' do
      expect(CPE::Helpers.rpm_installed?(
               'acme-tnt',
               "#{epoch}:20180628_115900_e2neh45ineht-1.acme.fc27",
               true,
      )).to eq(false)
    end
    it 'rpm_installed? returns false with unmatched E, epoch on' do
      expect(CPE::Helpers.rpm_installed?(
               'acme-tnt',
               "1:#{ver}-#{rel}",
               true,
      )).to eq(false)
    end
  end

  context 'When looking up an installed unepoched package' do
    epoch = '(none)'
    ver = '4.4.23'
    rel = '5.fc29'

    before do
      allow(CPE::Helpers).to receive(:shell_out).and_return(
        double(
          :error? => false,
          :stdout => "#{epoch}:#{ver}-#{rel}",
        ),
      )
    end
    it 'rpm_installed? returns true on a versionless match' do
      expect(CPE::Helpers.rpm_installed?('bash')).
        to eq(true)
    end
    it 'rpm_installed? returns true with matching VR, epoch off' do
      expect(CPE::Helpers.rpm_installed?(
               'bash', "#{ver}-#{rel}"
      )).to eq(true)
    end
    it 'rpm_installed? returns true with matching VR, epoch on' do
      expect(CPE::Helpers.rpm_installed?(
               'bash', "#{ver}-#{rel}", true
      )).to eq(true)
    end
    it 'rpm_installed? returns true with matching EVR, epoch on' do
      expect(CPE::Helpers.rpm_installed?(
               'bash', "0:#{ver}-#{rel}", true
      )).to eq(true)
    end
    it 'rpm_installed? returns false with unmatched VR, epoch off' do
      expect(CPE::Helpers.rpm_installed?(
               'bash', '4.4.23-2.fb1.el7'
      )).to eq(false)
    end
  end

  context 'When looking up a package with multiple versions' do
    rpm_qf = "rpm -q --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}'"
    ver = '0:4.18.16-300.fc29'
    before do
      allow(CPE::Helpers).to receive(:shell_out).
        with("#{rpm_qf} kernel").
        and_return(
          double(
            :error? => false,
            :stdout =>
            '(none):4.18.16-300.fc29(none):4.19.8-300.fc29',
          ),
        )
      allow(CPE::Helpers).to receive(:shell_out).
        with("#{rpm_qf} kernel-#{ver}").
        and_return(
          double(
            :error? => false,
            :stdout => '(none):4.18.16-300.fc29',
          ),
        )
    end
    it 'rpm_installed? returns true' do
      expect(CPE::Helpers.rpm_installed?(
               'kernel', ver
      )).to eq(true)
    end
  end
end
