# Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
name 'cpe_hosts'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
license 'Apache-2.0'
description 'Manages the entries in the /etc/hosts file'
source_url 'https://github.com/facebook/IT-CPE/tree/master/itchef/'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'
supports 'fedora'
supports 'mac_os_x'
supports 'windows'
depends 'line'
