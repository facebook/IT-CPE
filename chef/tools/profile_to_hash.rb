#!/usr/bin/env ruby

# Don't forget to install the gem!
# sudo gem install awesome_print

require 'plist'
require 'awesome_print'

input_file = ARGV[0]
profile_plist = Plist::parse_xml(input_file)
ap profile_plist, :indent => -2
