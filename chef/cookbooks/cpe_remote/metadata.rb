# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
name 'cpe_remote'
maintainer 'facebook, Inc'
maintainer_email 'mikedodge04@fb.com'
license 'All rights reserved'
description 'cpe_remote_pkg and cpe_remote_file '
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1'
supports 'mac_os_x'
supports 'windows'

depends 'cpe_utils'
depends 'cpe_logger'
