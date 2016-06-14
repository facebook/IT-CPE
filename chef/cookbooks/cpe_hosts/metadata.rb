# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

name 'cpe_hosts'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
license 'BSD'
description 'Manages the entries in the /etc/hosts file'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'

# This must be downloaded from https://supermarket.chef.io/cookbooks/line and
# placed into the cookbooks directory
depends 'line'
