# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_adobe_flash'
maintainer 'Facebook_IT-CPE'
maintainer_email 'noreply@facebook.com'
license 'BSD'
description 'Ensure flash configuration settings'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'cpe_choco'
depends 'cpe_launchd'
depends 'cpe_munki'
depends 'cpe_utils'

