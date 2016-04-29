#!/usr/bin/env ruby

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
