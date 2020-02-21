# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_munki'
maintainer 'Facebook'
maintainer_email 'it-cpe@fb.com'
license 'All rights reserved'
description 'Installs/Configures Munki'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'

depends 'cpe_remote'
depends 'cpe_utils'
depends 'cpe_profiles'
