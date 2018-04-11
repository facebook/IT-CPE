#
# Cookbook Name:: cpe_deprecation_notifier
# Attributes:: default
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

default['cpe_deprecation_notifier'] = {
  'enable' => false,
  'install' => false,
  # Writes prompt time to a json file.
  'log_path' => nil,
  'path' => '/Applications/DeprecationNotifier.app',
  'pkg_reciept' => 'com.deprecation_notifier',
  'checksum' => 'changeme',
  'version' => 'changeme',
  'conf' => {
    # The desired OS version.(e.g. 10.12.6)
    'expectedVersion' => '10.12.6',
    # The URL to open in the user's web browser,
    # which is opened when they close the window.
    'instructionURL' => 'changeme',
    # The message shown to the user below the countdown timer.
    # Can be up to 8 lines long.
    'deprecationMsg' => 'changeme',
    # The timeout the first time the user sees the notifier
    'initialTimeout' => '10',
    # The maximum amount of time the user is forced to wait
    'maxWindowTimeout' => '300',
    # Manages the speed at which the timeout goes up
    'timeoutMultiplier' => '1.1',
    # The time between notifications, in seconds
    'renotifyPeriod' => '3600',
    # List of Kiosk Mode options. In order to use these, you need to add the
    # numbers together and put the total for the 'kioskModeSettings' variable.
    # The default sets:
    #   'NSApplicationPresentationHideDock',
    #   'NSApplicationPresentationDisableProcessSwitching',
    #   'NSApplicationPresentationDisableForceQuit'
    # NSApplicationPresentationDefault = 0
    # NSApplicationPresentationAutoHideDock = 1
    # NSApplicationPresentationHideDock = 2
    # NSApplicationPresentationAutoHideMenuBar = 4
    # NSApplicationPresentationHideMenuBar = 8
    # NSApplicationPresentationDisableAppleMenu = 16
    # NSApplicationPresentationDisableProcessSwitching = 32
    # NSApplicationPresentationDisableForceQuit = 64
    # NSApplicationPresentationDisableSessionTermination = 128
    # NSApplicationPresentationDisableHideApplication = 256
    # NSApplicationPresentationDisableMenuBarTransparency = 512
    'kioskModeSettings' => '114',
  },
}
