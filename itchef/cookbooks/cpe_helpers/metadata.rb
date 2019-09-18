# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_helpers'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
license 'Apache-2.0'
description 'Helper methods for Facebook IT-CPE open-source cookbooks'
source_url 'https://github.com/facebook/IT-CPE/tree/master/itchef/'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

supports 'fedora'
supports 'mac_os_x'
supports 'windows'

depends 'fb_helpers'
