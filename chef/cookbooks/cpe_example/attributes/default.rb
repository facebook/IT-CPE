# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_example
# Attributes:: default
#
# Copyright (c) 2018, Facebook
# All rights reserved - Do Not Redistribute
#

# Only declare your basic attributes here.
# By default, these values should usually be `nil` or `false`, such that
# your cookbook should be a complete no-op if ran as-is.

# If you don't intend for someone to be able to overwrite this value,
# do not make it an attribute. All attributes are expected to be modifiable by
# any sort of customization.

# All of your default values for your cookbook should be done in
# cpe_base_settings (which apply to all nodes), or cpe_client (which apply only
# to client devices, which are employee laptops).
default['cpe_example'] = {
  'configure' => false,
  'pkg' => {},
}
