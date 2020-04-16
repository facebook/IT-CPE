# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Cookbook Name:: cpe_deprecation_notifier
# Attributes:: default

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
    # The desired OS build.(e.g. 17G3025)
    'expectedBuilds' => nil,
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
