# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_applocker
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

module CPE
  module Applocker
    # Statically defined types that we support for applocker rules
    APPLOCKER_TYPE_MAP ||= {
      'FilePathRule' => 'path',
      'FileHashRule' => 'hash',
      'FilePublisherRule' => 'certificate',
    }.freeze

    def self.gen_deterministic_uuid(seed)
      uuid = (Digest::SHA256.hexdigest seed).split(//).last(32).join
      pos = [8, 13, 18, 23]
      uuid = pos.map { |n| uuid = uuid.insert(n, '-') }[-1]
      uuid
    end

    def get_applocker_rules
      @applocker_rules ||= node['cpe_applocker']['applocker_rules'].dup
    end

    def cpe_applocker_enabled?
      @cpe_applocker_enabled ||= node['cpe_applocker']['enabled']
    end

    def set_applocker_policy
      powershell_script 'Apply updated Applocker configuration' do
        # not all data being passed in via the API is valid so this can fail.
        # skipping over errors for this until a proper maintainer is found
        ignore_failure true
        code <<-EOH
          # Ensure that the assemblies for managing Applocker are loaded, without
          # this we cannot load the AppLockerPolicy rendering functions used below
          [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.Security.ApplicationId.PolicyManagement.PolicyModel') | Out-Null
          [Microsoft.Security.ApplicationId.PolicyManagement.PolicyModel.AppLockerPolicy]::FromXml(
            ([xml]'#{gen_applocker_xml}').outerXML
          ) | Set-ApplockerPolicy
        EOH
      end
    end

    # Given an XML config from AppLocker, this should return a Hash with only
    # the values that we care about.
    def xml_to_hash(xml)
      policy = {
        'Appx' => { 'rules' => [] },
        'Dll' => { 'rules' => [] },
        'Exe' => { 'rules' => [] },
        'Msi' => { 'rules' => [] },
        'Script' => { 'rules' => [] },
      }
      xml.root.children.each do |elem|
        next unless elem.is_a?(Nokogiri::XML::Element)
        policy[elem['Type']]['mode'] = elem['EnforcementMode']

        # First get the metadata about each rule
        elem.children.each do |rule|
          # We only process rules we have definitions for
          next unless APPLOCKER_TYPE_MAP.key? rule.node_name
          type = APPLOCKER_TYPE_MAP[rule.name]
          pol_rule = {
            'type' => type,
            'name' => rule['Name'],
            'id' => rule['Id'],
            'action' => rule['Action'],
            'description' => rule['Description'],
            'user_or_group_sid' => rule['UserOrGroupSid'],
          }

          conditions = []
          # each rule has a `Condition` section, and there may be more than 1
          rule.children.each do |app_conditions|
            app_conditions.children.each do |condition|
              case type
              when 'path'
                next if condition['Path'].nil?
                conditions << { 'path' => condition['Path'] }
              when 'hash'
                condition.children.each do |filehash|
                  next if filehash['Data'].nil?
                  conditions << {
                    'type' => filehash['Type'],
                    'data' => filehash['Data'],
                    'file_name' => filehash['SourceFileName'],
                    'file_length' => filehash['SourceFileLength'],
                  }
                end
              when 'certificate'
                next if condition['PublisherName'].nil?
                bin_publisher = {
                  'publisher' => condition['PublisherName'],
                  'product_name' => condition['ProductName'],
                  'binary_name' => condition['BinaryName'],
                }
                # Get all of the binary version information
                condition.children.each do |binver|
                  next if binver['LowSection'].nil?
                  bin_publisher['binary_version'] = {}
                  bin_publisher['binary_version']['low'] = binver['LowSection']
                  bin_publisher['binary_version']['high'] = binver[
                    'HighSection'
                  ]
                end
                conditions << bin_publisher
              end
            end
          end
          pol_rule['conditions'] = conditions

          # And add the constructed rule to our ruleset
          policy[elem['Type']]['rules'] << pol_rule
        end
      end
      policy
    end

    def gen_file_path_rule(rule, xml)
      xml.FilePathRule(:Name => rule['name'],
                       :Id => rule['id'],
                       :Description => rule['description'],
                       :Action => rule['action'],
                       :UserOrGroupSid => rule['user_or_group_sid']) do
        xml.Conditions do
          rule['conditions'].each do |condition|
            xml.FilePathCondition(:Path => condition['path'])
          end # End of Each FilePathCondition
        end # End of Conditions
      end # End of FilePathRule
    end

    def gen_file_hash_rule(rule, xml)
      xml.FileHashRule(:Name => rule['name'],
                       :Id => rule['id'],
                       :Description => rule['description'],
                       :Action => rule['action'],
                       :UserOrGroupSid => rule['user_or_group_sid']) do
        xml.Conditions do
          rule['conditions'].each do |condition|
            xml.FileHashCondition do
              xml.FileHash(:Type => condition['type'],
                           :Data => condition['data'],
                           :SourceFileName => condition['file_name'],
                           :SourceFileLength => condition['file_length'])
            end
          end # End of FileHashCondition
        end # End of Conditions
      end # End of FileHashRule
    end

    def gen_file_publisher_rule(rule, xml)
      xml.FilePublisherRule(:Name => rule['name'],
                            :Id => rule['id'],
                            :Description => rule['description'],
                            :Action => rule['action'],
                            :UserOrGroupSid => rule['user_or_group_sid']) do
        xml.Conditions do
          rule['conditions'].each do |condition|
            xml.FilePublisherCondition(:PublisherName =>
                                          condition['publisher'],
                                       :ProductName =>
                                          condition['product_name'],
                                       :BinaryName =>
                                          condition['binary_name']) do
              xml.BinaryVersionRange(
                :LowSection => condition['binary_version']['low'],
                :HighSection => condition['binary_version']['high'],
              ) # End of BinaryVersionRange
            end # End of FilePublisherCondition
          end # End of Each file publisher condition
        end # End of Conditions
      end # End of FilePublisherRule
    end

    # Helper function to generate our XML configuration file
    def gen_applocker_xml
      require 'nokogiri'

      # Generical XML builder function. When enabled, this produces our
      # XML for enabling the Applocker service. When disabled, this produces
      # a "clean" XML policy for Applocker configuration
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.AppLockerPolicy(:Version => 1) do
          # Add to it each of our elements
          get_applocker_rules.map do |ruleset, opts|
            xml.RuleCollection(:Type => ruleset,
                               :EnforcementMode =>
                               cpe_applocker_enabled? ? opts['mode'] :
                               'NotConfigured') do
              opts['rules'].each do |rule|
                case rule['type']
                when 'path'
                  gen_file_path_rule(rule, xml)
                when 'hash'
                  gen_file_hash_rule(rule, xml)
                when 'certificate'
                  gen_file_publisher_rule(rule, xml)
                end
              end # opts['rules']
            end # End of RuleCollection
          end # End of Each Applocker ruleset, opts
        end # End of AppLockerPolicy
      end # End of Xml Builder
      builder.to_xml(
        :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML |
                      Nokogiri::XML::Node::SaveOptions::NO_DECLARATION,
      ).strip
    end
  end
end
