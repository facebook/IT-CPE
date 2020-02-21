# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_hosts'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
description 'Manages the entries in the /etc/hosts file'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'

depends 'cpe_utils'
depends 'line'
