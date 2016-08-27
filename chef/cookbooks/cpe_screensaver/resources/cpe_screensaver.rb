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
  if node['cpe_screensaver']['idleTime'] >= 600
    Chef::Log.warn(
      'Screensaver idle time is too long!'
    ) if warn
  end
  if node['cpe_screensaver']['askForPasswordDelay'] >= 5
    Chef::Log.warn(
      'Screensaver password delay is too long!'
    ) if warn
  end
  if node['cpe_screensaver']['MESSAGE'] &&
     node['cpe_screensaver']['SelectedFolderPath']
    Chef::Log.warn(
      'Screensaver module management has conflicting keys! \
      MESSAGE && SelectedFolderPath, sticking with MESSAGE'
    ) if warn
  end
  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  screensaver_profile = {
    'PayloadIdentifier' => "#{prefix}.screensaver",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => 'CEA1E58D-9D0F-453A-AA52-830986A8366C',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Screensaver',
<<<<<<< HEAD
    'PayloadContent' => []
  }

  screensaver_profile['PayloadContent'].push(
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
                node['cpe_screensaver']['askForPasswordDelay']
            }
          }
        ]
      }
    }
  )

  if node['cpe_screensaver']['MESSAGE']
    module_name = 'Computer Name'
    message = node['cpe_screensaver']['MESSAGE']
    screensaver_profile['PayloadContent'].push(
      'PayloadType' => 'com.apple.ManagedClient.preferences',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.screensaver.Basic",
      'PayloadUUID' => '8dd9a983-f59b-47c3-a408-ac55d287cbd4',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => message,
      'PayloadContent' => {
        'com.apple.screensaver.Basic.ByHost' => {
          'Forced' => [
            {
              'mcx_preference_settings' => {
                'MESSAGE' => message
              }
            }
          ]
        }
      }
    )
  end

  if node['cpe_screensaver']['MESSAGE'] ||
     node['cpe_screensaver']['SelectedFolderPath']
    resources = '/System/Library/Frameworks/ScreenSaver.framework/Resources/'
    module_name = module_name ? module_name : 'iLifeSlideshows'
    path = resources + module_name + '.saver'

    if node['cpe_screensaver']['SelectedFolderPath'].include? '.saver'
      resources = '/Library/Screen Savers/'
      module_name = node['cpe_screensaver']['SelectedFolderPath']
      path = resources + module_name
    end

    screensaver_profile['PayloadContent'].push(
      'PayloadType' => 'com.apple.ManagedClient.preferences',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.screensaver.ByHost",
      'PayloadUUID' => '01cb34f8-36f8-4fb6-babc-5ae3aa6c165b',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => module_name,
      'PayloadContent' => {
        'com.apple.screensaver.ByHost' => {
          'Forced' => [
            {
              'mcx_preference_settings' => {
                'moduleDict' => {
                  'moduleName' => module_name,
                  'path' => path,
                  'type' => 0
                }
              }
            }
          ]
        }
      }
    )
  end

  if module_name == 'iLifeSlideshows'
    style_key = node['cpe_screensaver']['styleKey']
    style_key ||= 'KenBurns'
    screensaver_profile['PayloadContent'].push(
      'PayloadType' => 'com.apple.ManagedClient.preferences',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.screensaver.iLifeSlideShows",
      'PayloadUUID' => 'c3efe8e7-3516-4438-a959-80f85a294035',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => style_key,
      'PayloadContent' => {
        'com.apple.ScreenSaver.iLifeSlideShows.ByHost' => {
          'Forced' => [
            {
              'mcx_preference_settings' => {
                'styleKey' => style_key
              }
            }
          ]
        }
      }
    )

    identifier = '/Library/Screen Savers/Default Collections'
    source = node['cpe_screensaver']['SelectedFolderPath']
    selected_folder = identifier + '/' + source
    selected_source = 3
    if source.include? '/'
      identifier = source
      selected_folder = source
      selected_source = 4
    end
    name = File.basename(identifier)
    shuffle_photos = node['cpe_screensaver']['ShufflesPhotos']
    shuffle_photos ||= 0
    screensaver_profile['PayloadContent'].push(
      'PayloadType' => 'com.apple.ManagedClient.preferences',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.screensaver.ScreenSaverPhotoChooser",
      'PayloadUUID' => '67775986-eab2-4723-a16c-3719397745fb',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => source,
      'PayloadContent' => {
        'com.apple.ScreenSaver.ScreenSaverPhotoChooser.ByHost' => {
          'Forced' => [
            {
              'mcx_preference_settings' => {
                'CustomFolderDict' => {
                  'identifier' => identifier,
                  'name' => name
                },
                'SelectedFolderPath' => selected_folder,
                'SelectedSource' => selected_source,
                'ShufflesPhotos' => shuffle_photos
              }
            }
          ]
        }
      }
    )
  end

  node.default['cpe_profiles']["#{prefix}.screensaver"] = screensaver_profile
end
