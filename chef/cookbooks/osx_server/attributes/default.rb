#
# Cookbook Name:: osx_server
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

# NBI attributes
default['cpe']['imaging_servers']['netboot_dir'] =
  '/Library/NetBoot/NetBootSP0/'

hostname_suffix = node['hostname'].split('-')[-1]
# OS X Server settings
default['cpe']['imaging_servers']['netboot'] = {
  'netboot:logging_level' => '"MEDIUM"',
  'netboot:filterEnabled' => 'no',
  'netboot:netBootPortsRecordsArray:_array_index:0:deviceAtIndex' => '"en0"',
  # 'netboot:netBootPortsRecordsArray:_array_index:0:nameAtIndex' => '"Ethernet"',
  'netboot:netBootPortsRecordsArray:_array_index:0:isEnabledAtIndex' => 'yes',
  'netboot:netBootStorageRecordsArray:_array_index:0:sharepoint' => 'yes',
  'netboot:netBootStorageRecordsArray:_array_index:0:clients' => 'no',
  'netboot:netBootStorageRecordsArray:_array_index:0:volType' => '"hfs"',
  'netboot:netBootStorageRecordsArray:_array_index:0:okToDeleteSharepoint' =>
    'no',
  'netboot:netBootStorageRecordsArray:_array_index:0:readOnlyShare' => 'no',
  'netboot:netBootStorageRecordsArray:_array_index:0:path' => '"/"',
  'netboot:netBootStorageRecordsArray:_array_index:0:okToDeleteClients' =>
    'yes',
  'netboot:netBootStorageRecordsArray:_array_index:0:volName' => '"ServerHD"',
  'netboot:netBootImagesRecordsArray:_array_index:0:pathToImage' =>
    "\"/Library/NetBoot/NetBootSP0/#{name}.nbi/NBImageInfo.plist\"",
  'netboot:netBootImagesRecordsArray:_array_index:0:IsInstall' => 'yes',
  'netboot:netBootImagesRecordsArray:_array_index:0:Kind' => '"2"',
  # Change the name that shows up during boot selection time here
  'netboot:netBootImagesRecordsArray:_array_index:0:Description' =>
    "#{node['hostname']}",
  'netboot:netBootImagesRecordsArray:_array_index:0:Name' =>
    hostname_suffix,
  'netboot:netBootImagesRecordsArray:_array_index:0:Index' => index,
  # 'netboot:netBootImagesRecordsArray:_array_index:0:osVersion' => '"10.10"',
  'netboot:netBootImagesRecordsArray:_array_index:0:BackwardCompatible' => 'no',
  'netboot:netBootImagesRecordsArray:_array_index:0:SupportsDiskless' => 'no',
  'netboot:netBootImagesRecordsArray:_array_index:0:BootFile' => '"booter"',
  'netboot:netBootImagesRecordsArray:_array_index:0:IsDefault' => 'yes',
  'netboot:netBootImagesRecordsArray:_array_index:0:Type' => '"NFS"',
  'netboot:netBootImagesRecordsArray:_array_index:0:Architectures' => '"4"',
  'netboot:netBootImagesRecordsArray:_array_index:0:IsEnabled' => 'yes',
  'netboot:netBootImagesRecordsArray:_array_index:0:RootPath' =>
    '"NetInstall.dmg"'
}

default['cpe']['imaging_servers']['caching'] = {
  'caching:ListenRangesOnly' => 'no',
  # Keep at least 25 GB of the disk free
  'caching:ReservedVolumeSpace' => '25000000000',
  # cache limit: 80 GB
  'caching:CacheLimit' => '80000000000',
  # local subnets only
  'caching:LocalSubnetsOnly' => 'yes',
  'caching:DataPath' => '"/Library/Server/Caching/Data"',
  'caching:ServerRoot' => '"/Library/Server"'
}

# See 'man sharing' for details
default['cpe']['imaging_servers']['sharing'] = {
  'path' => node['cpe']['imaging_servers']['ds_repo'],
  'name' => 'DeployStudio',
  # 100 for AFP, 010 for FTP, 001 for SMB. 101 = AFP + SMB
  'enable' => '101',
  'guest' => '101',
  # Disable inheriting privileges for AFP
  'inherit' => '00'
}

default['cpe']['imaging_servers']['sharing_correct'] =
"name:   DeployStudio
path:   #{node['cpe']['imaging_servers']['ds_repo']}
  afp:  {
        name: DeployStudio
        shared: 1
        guest access: 1
        inherit perms:  0
  }
  ftp:  {
        name: DeployStudio
        shared: 0
        guest access: 0
  }
  smb:  {
        name: DeployStudio
        shared: 1
        guest access: 1
  }"
