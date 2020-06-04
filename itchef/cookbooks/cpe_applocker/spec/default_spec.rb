# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_applocker
# Recipe:: default
#
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

require 'chefspec'
require 'nokogiri'
require_relative '../libraries/applocker_helpers'

def mock_cpe_applocker_enable(enabled)
  is_enabled = {
    'enabled' => enabled,
  }
  allow(applocker).to receive(:cpe_applocker_enabled?).and_return(is_enabled)
end

def mock_get_applocker_rules(enabled)
  mock_rules = {
    'Appx' => {
      'mode' => enabled ? 'AuditOnly' : 'NotConfigured',
      'rules' => [],
    },
    'Dll' => {
      'mode' => enabled ? 'Enforce' : 'NotConfigured',
      'rules' => [],
    },
    'Exe' => {
      'mode' => enabled ? 'Enforce' : 'NotConfigured',
      'rules' => enabled ? [
        # Rule to allow all applications for Administrators group
        {
          'type' => 'path',
          'name' => 'test_filepath',
          'id' => 'fd686d83-a829',
          'description' => 'Test file path rule set',
          'action' => 'Allow',
          'user_or_group_sid' => 'S-1-5-32-544',
          'conditions' => [
            {
              'path' => '%OSDRIVE%\\tools\\*',
            },
          ],
        },
        # Rule to ban calc.exe for everyone
        {
          'type' => 'hash',
          'name' => 'test_filehash',
          'id' => 'f8b0f25b-776f',
          'description' => 'Test file hash rule set',
          'action' => 'Deny',
          'user_or_group_sid' => 'S-1-1-0',
          'conditions' => [
            {
              'type' => 'SHA256',
              'data' => '0x267FEDEDD79AAAF7CFA62ECAA29BC0D' +
                        '8F5553FBD007A48BEC76C177BB7242CBC',
              'file_name' => 'calc.exe',
              'file_length' => '27648',
            },
          ],
        },
        # Rule to block Teamviewer publisher cert
        {
          'type' => 'certificate',
          'name' => 'test_filepublisher',
          'id' => 'acd2e5a8-6b8f',
          'description' => 'Test file publisher rule set',
          'action' => 'Deny',
          'user_or_group_sid' => 'S-1-1-0',
          'conditions' => [
            {
              'publisher' => 'O=TEAMVIEWER GMBH, L=GOPPINGEN, ' +
                             'S=BADEN-WURTTEMBERG, C=DE',
              'product_name' => '*',
              'binary_name' => '*',
              'binary_version' => { 'low' => '*', 'high' => '*' },
            },
          ],
        },
      ] : [],
    },
    'Script' => {
      'mode' => enabled ? 'AuditOnly' : 'NotConfigured',
      'rules' => [],
    },
    'Msi' => {
      'mode' => enabled ? 'AuditOnly' : 'NotConfigured',
      'rules' => [],
    },
  }
  allow(applocker).to receive(:get_applocker_rules).and_return(mock_rules)
end

describe CPE::Applocker do
  let(:applocker) { Class.new { extend CPE::Applocker } }

  applocker_configured = '<AppLockerPolicy Version="1"><RuleCollection ' +
    'Type="Appx" EnforcementMode="AuditOnly"/><RuleCollection Type="Dll" ' +
    'EnforcementMode="Enforce"/><RuleCollection Type="Exe" EnforcementMode=' +
    '"Enforce"><FilePathRule Name="test_filepath" Id="fd686d83-a829" ' +
    'Description="Test file path rule set" Action="Allow" UserOrGroupSid=' +
    '"S-1-5-32-544"><Conditions><FilePathCondition Path="%OSDRIVE%\tools' +
    '\*"/></Conditions></FilePathRule><FileHashRule Name="test_filehash" ' +
    'Id="f8b0f25b-776f" Description="Test file hash rule set" Action="Deny" ' +
    'UserOrGroupSid="S-1-1-0"><Conditions><FileHashCondition><FileHash ' +
    'Type="SHA256" Data="0x267FEDEDD79AAAF7CFA62ECAA29BC0D8F5553FBD007A4' +
    '8BEC76C177BB7242CBC" SourceFileName="calc.exe" SourceFileLength=' +
    '"27648"/></FileHashCondition></Conditions></FileHashRule><FilePublisher' +
    'Rule Name="test_filepublisher" Id="acd2e5a8-6b8f" Description="Test ' +
    'file publisher rule set" Action="Deny" UserOrGroupSid="S-1-1-0">' +
    '<Conditions><FilePublisherCondition PublisherName="O=TEAMVIEWER GMBH, ' +
    'L=GOPPINGEN, S=BADEN-WURTTEMBERG, C=DE" ProductName="*" BinaryName="*">' +
    '<BinaryVersionRange LowSection="*" HighSection="*"/></FilePublisher' +
    'Condition></Conditions></FilePublisherRule></RuleCollection><Rule' +
    'Collection Type="Script" EnforcementMode="AuditOnly"/><RuleCollection ' +
    'Type="Msi" EnforcementMode="AuditOnly"/></AppLockerPolicy>'

  applocker_disabled = '<AppLockerPolicy Version="1"><RuleCollection ' +
    'Type="Appx" EnforcementMode="NotConfigured"/><RuleCollection Type=' +
    '"Dll" EnforcementMode="NotConfigured"/><RuleCollection Type="Exe" ' +
    'EnforcementMode="NotConfigured"/><RuleCollection Type="Script" ' +
    'EnforcementMode="NotConfigured"/><RuleCollection Type="Msi" ' +
    'EnforcementMode="NotConfigured"/></AppLockerPolicy>'

  applocker_non_en_charset = <<EOF
<AppLockerPolicy Version="1">
  <RuleCollection Type="Exe" EnforcementMode="NotConfigured">
    <FilePublisherRule Name="test_filepublisher" Id="acd2e5a8-6b8f"
    Description="Test file publisher rule set"
    Action="Deny" UserOrGroupSid="S-1-1-0">
      <Conditions>
        <FilePublisherCondition
                  PublisherName="O=TEAMVIEWER GMBH, L=GÖPPINGEN, S=BADEN-WÜRTTEMBERG, C=DE"
                  ProductName="*" BinaryName="*">
          <BinaryVersionRange LowSection="*" HighSection="*"/>
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
  </RuleCollection>
</AppLockerPolicy>
EOF

  context 'When Applocker is enabled' do
    before do
      mock_cpe_applocker_enable(true)
      mock_get_applocker_rules(true)
    end
    it 'should render a valid xml string' do
      # Is this test valuable? Seems like we're just testing Nokogiris
      # ability to render XML correctly.
      expect(Nokogiri::XML(applocker.gen_applocker_xml).errors.length).to eql(0)
    end
    it 'should be different from NotConfigured settings' do
      expect(applocker.gen_applocker_xml).to eql(applocker_configured.strip)
    end
  end

  context 'When Applocker is disabled' do
    before do
      mock_cpe_applocker_enable(false)
      mock_get_applocker_rules(false)
    end
    it 'should render a valid xml string' do
      # Is this test valuable? Seems like we're just testing Nokogiris
      # ability to render XML correctly.
      expect(Nokogiri::XML(applocker.gen_applocker_xml).errors.length).to eql(0)
    end
    it 'should contain all NotConfigured settings' do
      expect(applocker.gen_applocker_xml).to eql(applocker_disabled.strip)
    end
  end

  # This is an explicit test to ensure that publishers with foreign
  # character sets are rendered and represented correctly by our helper
  # functions. This is important, as if we mess this up certificate deny/
  # allowlisting will break, thus I feel it merits its own test.
  context 'When processing data with non-EN charsets' do
    include CPE::Applocker
    it 'should properly render publisher information' do
      state = xml_to_hash(
        Nokogiri::XML(applocker_non_en_charset),
      )
      rule = state['Exe']['rules'][0]
      expect(rule['type']).to eql('certificate')
      expect(rule['conditions'][0]['publisher']).to eql(
        'O=TEAMVIEWER GMBH, L=GÖPPINGEN, S=BADEN-WÜRTTEMBERG, C=DE',
      )
    end
  end

  # Test the creation of our FilePathRules
  context 'When rendering FilePathRule xml' do
    include CPE::Applocker
    before do
      mock_cpe_applocker_enable(true)
      mock_get_applocker_rules(true)
    end
    it 'should return a valid applocker file path rule' do
      # First, create a 'stub' AppLocker policy with one FilePathRule
      rule = applocker.get_applocker_rules['Exe']['rules'][0]
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.AppLockerPolicy(:Version => 1) do
          xml.RuleCollection(:Type => 'Exe',
                             :EnforcementMode => 'NotConfigured') do
            gen_file_path_rule(rule, xml)
          end
        end # End of AppLockerPolicy
      end # End of Xml Builder

      # This expected policy has been tested applying on a local machine
      expected_policy = '<AppLockerPolicy Version="1"><RuleCollection ' +
        'Type="Exe" EnforcementMode="NotConfigured"><FilePathRule ' +
        'Name="test_filepath" Id="fd686d83-a829" Description="Test ' +
        'file path rule set" Action="Allow" UserOrGroupSid="S-1-5-32-' +
        '544"><Conditions><FilePathCondition Path="%OSDRIVE%\tools\*"' +
        '/></Conditions></FilePathRule></RuleCollection></AppLockerPolicy>'

      expect(builder.to_xml(
        :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML |
                      Nokogiri::XML::Node::SaveOptions::NO_DECLARATION,
      ).strip).to eql(expected_policy)
    end
  end

  # Test the creation of our FileHashRules
  context 'When rendering FileHashRules xml' do
    include CPE::Applocker
    before do
      mock_cpe_applocker_enable(true)
      mock_get_applocker_rules(true)
    end
    it 'should return a valid applocker file hash rule' do
      # First, create a 'stub' AppLocker policy with one FileHashRule
      rule = applocker.get_applocker_rules['Exe']['rules'][1]
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.AppLockerPolicy(:Version => 1) do
          xml.RuleCollection(:Type => 'Exe',
                             :EnforcementMode => 'NotConfigured') do
            gen_file_hash_rule(rule, xml)
          end
        end # End of AppLockerPolicy
      end # End of Xml Builder

      expected_policy = '<AppLockerPolicy Version="1"><RuleCollection ' +
        'Type="Exe" EnforcementMode="NotConfigured"><FileHashRule Name=' +
        '"test_filehash" Id="f8b0f25b-776f" Description="Test file hash ' +
        'rule set" Action="Deny" UserOrGroupSid="S-1-1-0"><Conditions>' +
        '<FileHashCondition><FileHash Type="SHA256" Data="0x267FEDEDD79' +
        'AAAF7CFA62ECAA29BC0D8F5553FBD007A48BEC76C177BB7242CBC" Source' +
        'FileName="calc.exe" SourceFileLength="27648"/></FileHash' +
        'Condition></Conditions></FileHashRule></RuleCollection>' +
        '</AppLockerPolicy>'

      expect(builder.to_xml(
        :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML |
                      Nokogiri::XML::Node::SaveOptions::NO_DECLARATION,
      ).strip).to eql(expected_policy)
    end
  end

  # Test the creation of our FilePublisherRules
  context 'When rendering FilePublisherRules xml' do
    include CPE::Applocker
    before do
      mock_cpe_applocker_enable(true)
      mock_get_applocker_rules(true)
    end
    it 'should return a valid applocker file publisher rule' do
      # First, create a 'stub' AppLocker policy with one FilePublisherRule
      rule = applocker.get_applocker_rules['Exe']['rules'][2]
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.AppLockerPolicy(:Version => 1) do
          xml.RuleCollection(:Type => 'Exe',
                             :EnforcementMode => 'NotConfigured') do
            gen_file_publisher_rule(rule, xml)
          end
        end # End of AppLockerPolicy
      end # End of Xml Builder

      expected_policy = '<AppLockerPolicy Version="1"><RuleCollection ' +
        'Type="Exe" EnforcementMode="NotConfigured"><FilePublisherRule ' +
        'Name="test_filepublisher" Id="acd2e5a8-6b8f" Description="Test ' +
        'file publisher rule set" Action="Deny" UserOrGroupSid="S-1-1-0">' +
        '<Conditions><FilePublisherCondition PublisherName="O=TEAMVIEWER ' +
        'GMBH, L=GOPPINGEN, S=BADEN-WURTTEMBERG, C=DE" ProductName="*" ' +
        'BinaryName="*"><BinaryVersionRange LowSection="*" HighSection=' +
        '"*"/></FilePublisherCondition></Conditions></FilePublisherRule>' +
        '</RuleCollection></AppLockerPolicy>'

      expect(builder.to_xml(
        :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML |
                      Nokogiri::XML::Node::SaveOptions::NO_DECLARATION,
      ).strip).to eql(expected_policy)
    end
  end

  # Put all of the pieces together to generate the full policy
  context 'When converting XML to a Hash' do
    include CPE::Applocker
    before do
      mock_cpe_applocker_enable(true)
      mock_get_applocker_rules(true)
    end
    it 'should render a known Applocker state' do
      # First, render our test state
      state = xml_to_hash(
        Nokogiri::XML(applocker.gen_applocker_xml),
      )

      # There should be 5 Configuration "states"
      expect(state.length).to eql(5)
      expect(state['Appx']['mode']).to eql('AuditOnly')
      expect(state['Exe']['mode']).to eql('Enforce')

      # Check the values we're parsing out for AppLocker
      rules = state['Exe']['rules']
      expect(rules.length).to eql(3)

      # The first rule is a FilePath rule
      expect(rules[0]['name']).to eql('test_filepath')
      expect(rules[0]['type']).to eql('path')
      expect(rules[0]['id']).to eql('fd686d83-a829')
      expect(rules[0]['description']).to eql('Test file path rule set')
      expect(rules[0]['user_or_group_sid']).to eql('S-1-5-32-544')
      expect(rules[0]['action']).to eql('Allow')
      # We only have 1 path condition currently
      expect(rules[0]['conditions'].length).to eql(1)
      expect(rules[0]['conditions'][0]['path']).to eql('%OSDRIVE%\\tools\\*')

      # The second rule is a FileHash rule
      expect(rules[1]['name']).to eql('test_filehash')
      expect(rules[1]['type']).to eql('hash')
      expect(rules[1]['id']).to eql('f8b0f25b-776f')
      expect(rules[1]['description']).to eql('Test file hash rule set')
      expect(rules[1]['user_or_group_sid']).to eql('S-1-1-0')
      expect(rules[1]['action']).to eql('Deny')
      # We only have 1 hash condition currently
      expect(rules[1]['conditions'].length).to eql(1)
      expect(rules[1]['conditions'][0]['type']).to eql('SHA256')
      expect(rules[1]['conditions'][0]['file_name']).to eql('calc.exe')
      expect(rules[1]['conditions'][0]['file_length']).to eql('27648')
      expect(rules[1]['conditions'][0]['data']).to eql('0x267FEDEDD79AAAF7CF' +
        'A62ECAA29BC0D8F5553FBD007A48BEC76C177BB7242CBC')

      # The third rule is a FilePublisher rule
      expect(rules[2]['name']).to eql('test_filepublisher')
      expect(rules[2]['type']).to eql('certificate')
      expect(rules[2]['id']).to eql('acd2e5a8-6b8f')
      expect(rules[2]['description']).to eql('Test file publisher rule set')
      expect(rules[2]['user_or_group_sid']).to eql('S-1-1-0')
      expect(rules[2]['action']).to eql('Deny')
      # We only have 1 certificate condition currently
      expect(rules[2]['conditions'].length).to eql(1)
      expect(rules[2]['conditions'][0]['binary_name']).to eql('*')
      expect(rules[2]['conditions'][0]['product_name']).to eql('*')
      expect(rules[2]['conditions'][0]['binary_version']['low']).to eql('*')
      expect(rules[2]['conditions'][0]['binary_version']['high']).to eql('*')
      expect(rules[2]['conditions'][0]['publisher']).to eql('O=TEAMVIEWER ' +
        'GMBH, L=GOPPINGEN, S=BADEN-WURTTEMBERG, C=DE')
    end
  end
end
