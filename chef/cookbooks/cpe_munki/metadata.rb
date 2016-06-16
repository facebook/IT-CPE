# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

name 'cpe_munki'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
license 'BSD'
description 'Installs/Configures Munki'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'

depends 'cpe_remote'
depends 'cpe_utils'
depends 'mac_os_x'
