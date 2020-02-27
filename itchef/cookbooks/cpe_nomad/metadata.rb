# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_nomad'
maintainer 'Facebook'
maintainer_email 'noreply@fb.com'
license 'Apache-2.0'
description 'Installs/configures NoMAD'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'fb_launchd'
depends 'cpe_logger'
depends 'cpe_profiles'
