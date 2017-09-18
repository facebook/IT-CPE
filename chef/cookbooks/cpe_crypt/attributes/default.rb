# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_crypt
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

default['cpe_crypt'] = {
  'install' => false,
  'configure' => false,
  'prefs' => {
    # The ServerURL preference sets your Crypt Server. Crypt will not enforce
    # FileVault if this preference isn't set. EX: "https://crypt.example.com"
    'ServerURL' => nil, # String
    # The SkipUsers preference allows you to define an array of users that will
    # not be forced to enable FileVault. ['adminuser', 'mikedodge04']
    'SkipUsers' => nil, # Array
    # By default, the plist with the FileVault Key will be removed once it has
    # been escrowed. In a future version of Crypt, there will be the
    # possibility of verifying the escrowed key with the client. In preparation
    # for this feature, you can now choose to leave the key on disk. bool
    'RemovePlist' => nil, # Bool
    # Crypt2 can rotate the recovery key, if the key is used to unlock the disk.
    # There is a small caveat that this feature only works if the key is still
    # present on the disk. This is set to TRUE by default.
    'RotateUsedKey' => nil, # Bool
    # Crypt2 can validate the recovery key if it is stored on disk. If the key
    # fails validation, the plist is removed so it can be regenerated on next
    # login. This is set to TRUE by default.
    'ValidateKey' => nil, # Bool
    # Crypt 2 can optionally add new users to be able to unlock FileVault 2
    # volumes (when the disk is unlocked). This feature works up until macOS
    # 10.12. The default for this is FALSE.
    'FDEAddUser' => nil, # Bool
    # As of version 2.3.0 you can now define a new location for where the
    # recovery key is written to. Default for this is
    # '/var/root/crypt_output.plist'.
    'OutputPath' => nil, # Srting
    # As of version 2.3.0 you can now define the time interval in Hours for how
    # often Crypt tries to re-escrow the key, after the first successful escrow.
    # Default for this is 1 hour.
    'KeyEscrowInterval' => nil, # int
  },
  'pkg' => {
    'name' => 'crypt',
    'version' => nil,
    'checksum' => nil,
    'receipt' => 'com.grahamgilbert.crypt',
    'pkg_name' => nil,
    'pkg_url' => nil,
  },
}
