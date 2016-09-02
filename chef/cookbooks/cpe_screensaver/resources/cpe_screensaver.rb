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
  if node['cpe_screensaver']['idleTime'] > 600
    Chef::Log.warn(
      'Screensaver idle time is too long!',
    ) if warn
  end
  if node['cpe_screensaver']['askForPasswordDelay'] > 5
    Chef::Log.warn(
      'Screensaver password delay is too long!',
    ) if warn
  end
  if node['cpe_screensaver']['MESSAGE'] &&
     node['cpe_screensaver']['SelectedFolderPath']
    Chef::Log.warn(
      'Screensaver module management has conflicting keys \
      MESSAGE && SelectedFolderPath! Sticking with MESSAGE',
    ) if warn
  end
  if ([
    'Shell',
    'iTunes Artwork',
    'Arabesque',
    'Word of the Day',
  ].include? node['cpe_screensaver']['SelectedFolderPath']) &&
  node.os_greater_than?('10.11')
    Chef::Log.warn(
      'Chosen screensaver module not available until El-Capitan!',
    ) if warn
  end
  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  # Create the base profile hash to avoid at least a little duplication
  screensaver_profile = {
    'PayloadIdentifier' => "#{prefix}.screensaver",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => 'CEA1E58D-9D0F-453A-AA52-830986A8366C',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Screensaver',
    'PayloadContent' => [],
  }

  # Appends the non-optional com.apple.screensaver payload to the profile hash.
  # If the remaining attrbutes are nil, this payload is the only thing the
  # profile will contain along with the base profile hash
  # Note the quirky nature of profiles... the idleTime key is specified here
  # even though the value is typically stored in the ByHost preferences
  # when using the UI or the defaults command
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
              'askForPassword' =>
                node['cpe_screensaver']['askForPassword'],
              'askForPasswordDelay' =>
                node['cpe_screensaver']['askForPasswordDelay'],
              'idleTime' => node['cpe_screensaver']['idleTime'],
            },
          },
        ],
      },
    },
  )

  # Appends the following domain payloads to the profile hash if ANY of the
  # conditional attributes are non nil;
  # com.apple.screensaver.Basic.ByHost
  # com.apple.screensaver.ByHost
  # com.apple.ScreenSaverPhotoChooser.ByHost
  # com.apple.ScreenSaver.iLifeSlideShows.ByHost
  if node['cpe_screensaver']['MESSAGE'] ||
     node['cpe_screensaver']['SelectedFolderPath']

    # Default values
    ss_type = '/Library/Screen Savers/'
    ss_num = 0
    ss_module = node['cpe_screensaver']['SelectedFolderPath']
    ss_ext = '.saver'

    # Values for traditional built-in screensavers (.saver)
    if [
      'Flurry',
      'Shell',
      'iTunes Artwork',
      'Random',
    ].include? ss_module
      ss_type = '/System/Library/Screen Savers/'
    end

    # Values for traditional built-in screensavers (quartz)
    if [
      'Arabesque',
      'Word of the Day',
    ].include? ss_module
      ss_type = '/System/Library/Screen Savers/'
      ss_num = 1
      ss_ext = '.qtz'
    end

    # Values for iLifeSlideshows built-in screensavers
    if [
      '1-National Geographic',
      '2-Aerial',
      '3-Cosmos',
      '4-Nature Patterns',
      '/Users/cgerke/Pictures',
    ].include? ss_module
      ss_type = '/System/Library/Frameworks/ScreenSaver.framework/Resources/'
      ss_module = 'iLifeSlideshows'
    end

    # Values for iLifeSlideshows built-in screensavers (custom folder)
    if ss_module.include?('/')
      ss_type = '/System/Library/Frameworks/ScreenSaver.framework/Resources/'
      ss_module = 'iLifeSlideshows'
    end

    # Appends the com.apple.screensaver.Basic.ByHost payload to the profile hash
    # if the conditional attribute is non nil. Sets the appropriate values for
    # the MESSAGE style screensaver
    if node['cpe_screensaver']['MESSAGE']
      ss_type = '/System/Library/Frameworks/ScreenSaver.framework/Resources/'
      ss_module = 'Computer Name'
      ss_message = node['cpe_screensaver']['MESSAGE']
      screensaver_profile['PayloadContent'].push(
        'PayloadType' => 'com.apple.ManagedClient.preferences',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.screensaver.Basic",
        'PayloadUUID' => '8dd9a983-f59b-47c3-a408-ac55d287cbd4',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => message,
        'PayloadContent' => {
          'com.apple.screensaver.Basic.ByHost' => {
            'Set-Once' => [
              {
                'mcx_preference_settings' => {
                  'MESSAGE' => ss_message,
                },
              },
            ],
          },
        },
      )
    end

    # Appends the com.apple.screensaver.ByHost payload to the profile hash
    # with appropriate values for the following style screensavers;
    # MESSAGE, built-in, 3rd party, custom folder
    # Note we set the idleTime value her too...this is where the key is meant
    # to be, if the profile is remove it will stick around.
    screensaver_profile['PayloadContent'].push(
      'PayloadType' => 'com.apple.ManagedClient.preferences',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.screensaver.ByHost",
      'PayloadUUID' => '01cb34f8-36f8-4fb6-babc-5ae3aa6c165b',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => ss_module,
      'PayloadContent' => {
        'com.apple.screensaver.ByHost' => {
          'Set-Once' => [
            {
              'mcx_preference_settings' => {
                'idleTime' => node['cpe_screensaver']['idleTime'],
                'moduleDict' => {
                  'moduleName' => ss_module,
                  'path' => ss_type + ss_module + ss_ext,
                  'type' => ss_num,
                },
              },
            },
          ],
        },
      },
    )
  end

  # Appends the com.apple.ScreenSaver.iLifeSlideShows.ByHost payload and
  # com.apple.ScreenSaverPhotoChooser.ByHost payload to the
  # profile hash if the condition is satisfied. Sets appropriate values for the
  # following style screensavers;
  # built-in, custom folder
  if ss_module == 'iLifeSlideshows'
    ss_type = '/Library/Screen Savers/Default Collections'
    ss_module = node['cpe_screensaver']['SelectedFolderPath']
    # Using directory marker / to test if the end user has added a custom
    # folder to the SelectedFolderPath attribute
    selected_folder = ss_type + '/' + ss_module
    selected_source = 3
    if ss_module.include? '/'
      ss_type = ss_module
      selected_folder = ss_module
      selected_source = 4
    end
    ss_name = ss_type.split('/').last
    # Set ShufflesPhotos to false if the attribute is nil, basically just to
    # reduce the number of attributes a user HAS to set in a node customisation
    shuffle_photos = node['cpe_screensaver']['ShufflesPhotos']
    shuffle_photos = shuffle_photos ? shuffle_photos : 0
    # Set styleKey to KenBurns if the attribute is nil, basically just to
    # reduce the number of attributes a user HAS to set in a node customisation
    style_key = node['cpe_screensaver']['styleKey']
    style_key = style_key ? style_key : 'KenBurns'
    # Appends the com.apple.ScreenSaverPhotoChooser.ByHost payload to the
    # profile hash with appropriate values for the following style screensavers;
    # built-in, custom folder
    screensaver_profile['PayloadContent'].push(
      {
        'PayloadType' => 'com.apple.ManagedClient.preferences',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.screensaver.ScreenSaverPhotoChooser",
        'PayloadUUID' => '67775986-eab2-4723-a16c-3719397745fb',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => ss_module,
        'PayloadContent' => {
          'com.apple.ScreenSaverPhotoChooser.ByHost' => {
            'Set-Once' => [
              {
                'mcx_preference_settings' => {
                  'CustomFolderDict' => {
                    'identifier' => ss_type,
                    'name' => ss_name,
                  },
                  'SelectedFolderPath' => selected_folder,
                  'SelectedSource' => selected_source,
                  'ShufflesPhotos' => shuffle_photos,
                },
              },
            ],
          },
        },
      },
      {
        'PayloadType' => 'com.apple.ManagedClient.preferences',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.screensaver.iLifeSlideShows",
        'PayloadUUID' => 'c3efe8e7-3516-4438-a959-80f85a294035',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => style_key,
        'PayloadContent' => {
          'com.apple.ScreenSaver.iLifeSlideShows.ByHost' => {
            'Set-Once' => [
              {
                'mcx_preference_settings' => {
                  'styleKey' => style_key,
                },
              },
            ],
          },
        },
      },
    )
  end

  node.default['cpe_profiles']["#{prefix}.screensaver"] = screensaver_profile
end
