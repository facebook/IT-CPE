# Copyright 2022-present, Meta Platforms, Inc.
# All rights reserved - Do not redistribute
#

module FB
  class Bluetooth
    def self.profile_name(node)
      "#{node['cpe_profiles']['prefix']}.bluetooth"
    end

    def self.base_profile(profile_name, organization)
      {
        'PayloadIdentifier' => profile_name,
        'PayloadRemovalDisallowed' => true,
        'PayloadScope' => 'System',
        'PayloadType' => 'Configuration',
        'PayloadUUID' => '2E33AB8C-AFF6-4BA7-8110-412EC841423E',
        'PayloadOrganization' => organization,
        'PayloadVersion' => 1,
        'PayloadDisplayName' => 'Bluetooth',
        'PayloadContent' => [{
          'PayloadType' => 'com.apple.Bluetooth',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => profile_name,
          'PayloadUUID' => '37F77492-E026-423F-8F7B-567CC06A7585',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'Bluetooth',
        }],
      }
    end

    def self.generate_profile(node)
      return {} unless node['fb_bluetooth']

      prefs = node['fb_bluetooth'].reject { |k, _v| node['fb_bluetooth'][k].nil? }

      if prefs.empty?
        Chef::Log.info('fb_bluetooth: No prefs found.')
        return
      end

      organization = node['organization'] ? node['organization'] : 'Facebook'

      profile_name = self.profile_name(node)
      profile = self.base_profile(profile_name, organization)

      prefs.each do |k, _v|
        profile['PayloadContent'][0][k] = node['fb_bluetooth'][k]
      end

      profile
    end
  end
end
