# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

name 'cpe_init'
maintainer 'Facebook, Inc'
maintainer_email 'noreply@facebook.com'
license 'BSD'
description 'This is the very basic cookbook that starts it all.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

# Multi-platform
depends 'cpe_user_customizations'
depends 'cpe_node_customizations'
depends 'cpe_utils'


### API Cookbooks
depends 'cpe_bluetooth'
depends 'cpe_hosts'
depends 'cpe_launchd'
depends 'cpe_munki'
depends 'cpe_nightly_reboot'
depends 'cpe_pathsd'
depends 'cpe_powermanagement'
depends 'cpe_profiles'
depends 'cpe_prompt_user'
depends 'cpe_screensaver'

## Web Browser API Cookbooks
depends 'cpe_safari'
