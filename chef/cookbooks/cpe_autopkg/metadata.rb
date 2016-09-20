# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
name 'cpe_autopkg'
maintainer 'Facebook'
maintainer_email 'it-cpe@fb.com'
license 'All rights reserved'
description 'Installs/Configures AutoPkg Test Environment'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

# depends 'cpe_remote'
depends 'cpe_profiles'
depends 'mac_os_x'
