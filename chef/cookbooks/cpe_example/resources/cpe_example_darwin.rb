# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_example
# Resource:: cpe_example
#
# Copyright (c) 2018, Facebook
# All rights reserved - Do Not Redistribute
#

# You'll generally want a custom resource for each platform that provides
# functionality for each specific OS.
resource_name :cpe_example_darwin
# The value for "provides" is the actual name of the custom resource that is
# called from your recipes/default.rb file.
# Even though this file is named "cpe_example_darwin" (because it's macOS-only),
# it provides a custom resource that can be called with "cpe_example".
# The "os" is what OSes this resource is supported to run on.
# Chef will throw an error and halt if you call a custom resource on a platform
# that is not supported.
provides :cpe_example, :os => 'darwin'
# You can specify multiple actions for a custom resource, but typically
# you'll only ever need one. This default_action corresponds to the action
# section below.
default_action :install

action_class do
  # This includes your library helpers, defined in
  # cpe_example/libraries/example_helpers.rb
  # By including it here, you can simply use library functions in your custom
  # resource
  include CPE::Example
end

action :install do
  # This will install an Apple package from Pantri
  # Pantri information:
  # https://our.internmc.facebook.com/intern/wiki/IT_Frontpage/CPE/ops/Pantri/
  # See the cpe_remote README for more details.
  cpe_remote_pkg 'example' do
    receipt  node['cpe_example']['pkg']['name']
    version  node['cpe_example']['pkg']['version']
    checksum node['cpe_example']['pkg']['checksum']
  end

  # This is defined in the library, and explicitly included above,
  # so you can just call it directly in this resource
  example_function
end
