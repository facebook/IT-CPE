# Copyright (c) Facebook, Inc. and its affiliates.
name 'cpe_init'
maintainer 'Facebook'
maintainer_email 'noreply@facebook.com'
license 'Apache-2.0'
description 'This is the very basic cookbook that starts it all.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

# Multi-platform
depends 'cpe_helpers'
depends 'cpe_user_customizations'
depends 'cpe_node_customizations'

# borrowed from facebook/chef-cookbooks
depends 'fb_helpers'
depends 'fb_launchd'

# deprecated
depends 'cpe_launchd'

### API Cookbooks
depends 'cpe_adobe_flash'
depends 'cpe_applocker'
depends 'cpe_bluetooth'
depends 'cpe_dconf'
depends 'cpe_deprecation_notifier'
depends 'cpe_flatpak'
depends 'cpe_gnome_software'
# depends 'cpe_hosts' # requires 'line' community cookbook
depends 'cpe_logger'
depends 'cpe_munki'
depends 'cpe_nomad'
depends 'cpe_pathsd'
depends 'cpe_powermanagement'
depends 'cpe_preferencepanes'
depends 'cpe_profiles'
depends 'cpe_remote'
depends 'cpe_spotlight'
depends 'cpe_symlinks'
depends 'cpe_vfuse'
depends 'cpe_win_telemetry'

## Web Browser API Cookbooks
depends 'cpe_chrome'
