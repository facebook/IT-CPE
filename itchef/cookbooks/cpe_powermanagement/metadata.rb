# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_powermanagement'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
license 'Apache-2.0'
description 'Manages powermanagement settings / profile'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'
supports 'mac_os_x'

depends 'cpe_helpers'
depends 'cpe_profiles'
