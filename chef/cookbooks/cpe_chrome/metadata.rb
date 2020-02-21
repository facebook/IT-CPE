# Copyright (c) Facebook, Inc. and its affiliates.

name 'cpe_chrome'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
description 'Manage and configure Chrome browser'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'cpe_choco'
depends 'cpe_profiles'
depends 'cpe_utils'
