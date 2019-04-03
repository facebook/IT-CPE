# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_example
# Recipe:: default
#
# Copyright (c) 2018, Facebook
# All rights reserved - Do Not Redistribute
#

# Always gate your recipe to the appropriate OSes!
return unless node.macos?

# Call the custom resource to handle all of your work
cpe_example 'Demonstrates an example cookbook' do
  # The most basic gate is whether or not the 'configure' attribute is true
  # This allows users to turn your cookbook on or off.
  only_if { node['cpe_example']['configure'] }
end
