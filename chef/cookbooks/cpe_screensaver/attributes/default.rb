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

default['cpe_screensaver']['idleTime'] = 600
default['cpe_screensaver']['askForPassword'] = 1
default['cpe_screensaver']['askForPasswordDelay'] = 0

# Although you can manage the screensaver "modules" with profiles, the ui is not locked down like it
# is with the screensaver "security" options

# TODO : think about real world usage, make it less confusing, no point setting a MESSAGE and iLifeSlideshows etc

# Defaults to node['organization'] if nil
default['cpe_screensaver']['MESSAGE'] = nil

# USAGE : Computer Name, iLifeSlideshows
default['cpe_screensaver']['moduleName'] = 'Computer Name'

# Transition style, only valid when moduleName is iLifeSlideshows, defaults to KenBurns if nil
# USAGE : Floating, Flipup, Reflections, Origami, ShiftingTiles, SlidingPanels, PhotoMobile, HolidayMobile, PhotoWall, VintagePrints, KenBurns, Classic
default['cpe_screensaver']['styleKey'] = nil

# A Default Collection "source" is only valid when moduleName is iLifeSlideshows, defaults to 4-Nature Patterns if nil
# USAGE : 1-National Geographic, 2-Aerial, 3-Cosmos, 4-Nature Patterns, or a Custom Folder Path
default['cpe_screensaver']['SelectedFolderPath'] = nil

# USAGE : 0, 1
default['cpe_screensaver']['ShufflesPhotos'] = 0