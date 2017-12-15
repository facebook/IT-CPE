# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

name 'cpe_screensaver'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
license 'All rights reserved'
description 'Installs/Configures cpe_screensaver'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'
supports 'mac_os_x'

depends 'cpe_utils'
depends 'cpe_profiles'
