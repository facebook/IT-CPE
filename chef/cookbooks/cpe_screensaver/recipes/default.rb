#
# Cookbook Name:: cpe_screensaver
# Recipe:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

# Enforce screen saver settings
ruby_block 'screensaver_profile' do
  block do
    unless node['cpe_screensaver']['idleTime'] <= 600
      Chef::Log.warn(
        'Screensaver idle time is too high!'
      )
    end
    unless node['cpe_screensaver']['askForPasswordDelay'] <= 5
      Chef::Log.warn(
        'Screensaver password delay is too high!'
      )
    end
    
    prefix = node['cpe_profiles']['prefix']
    organization = node['organization'] ? node['organization'] : 'Facebook'

    # if the MESSAGE attribute is nil, use a default, "organization"
    MESSAGE = node['cpe_screensaver']['MESSAGE'] ? node['cpe_screensaver']['MESSAGE'] : organization
    path = '/System/Library/Frameworks/ScreenSaver.framework/Resources/' + node['cpe_screensaver']['moduleName'] + '.saver'

    node.default['cpe_profiles']["#{prefix}.screensaver"] = {
      'PayloadIdentifier' => "#{prefix}.screensaver",
      'PayloadRemovalDisallowed' => true,
      'PayloadScope' => 'System',
      'PayloadType' => 'Configuration',
      'PayloadUUID' => 'CEA1E58D-9D0F-453A-AA52-830986A8366C',
      'PayloadOrganization' => organization,
      'PayloadVersion' => 1,
      'PayloadDisplayName' => 'Screensaver',
      'PayloadContent' => [
        {
          'PayloadType' => 'com.apple.ManagedClient.preferences',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => "#{prefix}.screensaver",
          'PayloadUUID' => '3B2AD6A9-F99E-4813-980A-4147617B2E75',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'ScreenSaver',
          'PayloadContent' => {
            'com.apple.screensaver' => {
              'Forced' => [
                {
                  'mcx_preference_settings' => {
                    'idleTime' => node['cpe_screensaver']['idleTime'],
                    'askForPassword' => node['cpe_screensaver']['askForPassword'],
                    'askForPasswordDelay' => node['cpe_screensaver']['askForPasswordDelay']
                  }
                }
              ]
            }
          }
        },
        {
          'PayloadType' => 'com.apple.ManagedClient.preferences',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => "#{prefix}.screensaver.ByHost",
          'PayloadUUID' => '01cb34f8-36f8-4fb6-babc-5ae3aa6c165b',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'moduleName',
          'PayloadContent' => {
            'com.apple.screensaver.ByHost' => {
              'Forced' => [
                {
                  'mcx_preference_settings' => {
                    'moduleDict' => {
                      'moduleName' => node['cpe_screensaver']['moduleName'],
                      'path' => path,
                      'type' => 0
                    }
                  }
                }
              ]
            }
          }
        },
        {
          'PayloadType' => 'com.apple.ManagedClient.preferences',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => "#{prefix}.screensaver.Basic",
          'PayloadUUID' => '8dd9a983-f59b-47c3-a408-ac55d287cbd4',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'MESSAGE',
          'PayloadContent' => {
            'com.apple.screensaver.Basic.ByHost' => {
              'Forced' => [
                {
                  'mcx_preference_settings' => {
                    'MESSAGE' => MESSAGE
                  }
                }
              ]
            }
          }
        }
      ]
    }
  end
end
