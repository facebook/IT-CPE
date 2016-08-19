#
# Cookbook Name:: cpe_screensaver
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

# TODO : think about real world usage some more!, make it less confusing, no point setting a MESSAGE and iLifeSlideshows etc
# TODO : think about lock down, consider <key>DisabledPreferencePanes</key>

default['cpe_screensaver']['idleTime'] = 600
default['cpe_screensaver']['askForPassword'] = 1
default['cpe_screensaver']['askForPasswordDelay'] = 0

# USAGE : add a string value like this example, defaults to node['organization'] if nil
#default['cpe_screensaver']['MESSAGE'] = 'Unauthorised access is prohibited'

# AND

# USAGE : Computer Name, iLifeSlideshows
default['cpe_screensaver']['moduleName'] = ''

#### OR ####

# USAGE : uncomment a transition style, defaults to KenBurns if nil
#default['cpe_screensaver']['styleKey'] = Floating
#default['cpe_screensaver']['styleKey'] = Flipup
#default['cpe_screensaver']['styleKey'] = Reflections
#default['cpe_screensaver']['styleKey'] = Origami
#default['cpe_screensaver']['styleKey'] = ShiftingTiles
#default['cpe_screensaver']['styleKey'] = SlidingPanels
#default['cpe_screensaver']['styleKey'] = PhotoMobile
#default['cpe_screensaver']['styleKey'] = HolidayMobile
#default['cpe_screensaver']['styleKey'] = PhotoWall
#default['cpe_screensaver']['styleKey'] = VintagePrints
#default['cpe_screensaver']['styleKey'] = KenBurns
#default['cpe_screensaver']['styleKey'] = Classic

# AND

# USAGE : uncomment a "source", defaults to 4-Nature Patterns if nil
#default['cpe_screensaver']['SelectedFolderPath'] = 1-National Geographic
#default['cpe_screensaver']['SelectedFolderPath'] = 2-Aerial
#default['cpe_screensaver']['SelectedFolderPath'] = 3-Cosmos
#default['cpe_screensaver']['SelectedFolderPath'] = 4-Nature Patterns
# set a Custom Folder Path by uncommenting this
#default['cpe_screensaver']['SelectedFolderPath'] = '/Users/YOURUSERNAME/Pictures'

# USAGE : uncomment to shuffle the "source"
#default['cpe_screensaver']['ShufflesPhotos'] = 1
