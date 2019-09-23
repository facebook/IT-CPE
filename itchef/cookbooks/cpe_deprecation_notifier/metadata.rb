# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_deprecation_notifier'
maintainer 'IT-CPE'
maintainer_email 'noreply@facebook.com'
license 'Apache-2.0'
description 'Installs and configures deprecation notifier'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'cpe_logger'
depends 'cpe_remote'
depends 'cpe_helpers'
