#!/usr/bin/env ruby
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

required_gems = ['plist', 'awesome_print']
required_gems.each do |required_gem|
  begin
    require required_gem
  rescue LoadError
    abort("You must install the #{required_gem} gem")
  end
end

input_file = ARGV[0]
profile_plist = Plist::parse_xml(input_file)
ap profile_plist, :indent => -2, :index => false
