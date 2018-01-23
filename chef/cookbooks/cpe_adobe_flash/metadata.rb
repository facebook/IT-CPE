# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
name 'cpe_adobe_flash'
maintainer 'Facebook_IT-CPE'
maintainer_email 'noreply@facebook.com'
license 'All rights reserved'
description 'Ensure flash configuration settings'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'cpe_choco'
depends 'cpe_launchd'
depends 'cpe_munki'
depends 'cpe_utils'
