# Cookbook Name:: cpe_flatpak
# Recipe:: default
#
# (c) Facebook, Inc. and its affiliates. Confidential and proprietary.

return unless node.linux?

cpe_flatpak 'Manage Flatpak'
