#
# Cookbook Name:: cpe_screensaver
# Resource:: cpe_screensaver
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

resource_name :cpe_screensaver
default_action :config

action :config do
  # Enforce screen saver settings
  warn = node['cpe_screensaver']['__nowarn'] ? false : true
  if node['cpe_screensaver']['idleTime'] &&
     node['cpe_screensaver']['idleTime'] >= 600
    if warn
      Chef::Log.warn(
        'Screensaver idle time is too long!',
      )
    end
  end
  if node['cpe_screensaver']['askForPasswordDelay'] &&
     node['cpe_screensaver']['askForPasswordDelay'] >= 5
    if warn
      Chef::Log.warn(
        'Screensaver password delay is too long!',
      )
    end
  end
  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
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
                  'askForPassword' =>
                    node['cpe_screensaver']['askForPassword'],
                  'askForPasswordDelay' =>
                    node['cpe_screensaver']['askForPasswordDelay'],
                },
              },
            ],
          },
        },
      },
    ],
  }
end
