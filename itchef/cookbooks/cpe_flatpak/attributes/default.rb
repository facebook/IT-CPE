#
# Cookbook Name:: cpe_flatpak
# Attributes:: default
#
# (c) Facebook, Inc. and its affiliates. Confidential and proprietary.
#

default['cpe_flatpak'] = {
  'ignore_failure' => false,
  'manage' => false,
  'remotes' => { 'flathub' => 'https://flathub.org/repo/flathub.flatpakrepo' },
  'pkgs' => {},
}
