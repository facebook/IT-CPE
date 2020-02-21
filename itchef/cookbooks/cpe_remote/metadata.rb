# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_remote'
maintainer 'Facebook'
maintainer_email 'noreply@fb.com'
license 'Apache-2.0'
description 'cpe_remote_pkg and cpe_remote_file '
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1'
supports 'fedora'
supports 'mac_os_x'
supports 'windows'

depends 'cpe_helpers'
depends 'cpe_logger'
