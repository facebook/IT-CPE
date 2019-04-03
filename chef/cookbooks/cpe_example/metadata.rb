# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
name 'cpe_example'
maintainer 'your team name goes here'
maintainer_email 'oncall+your_oncall_name_here@xmail.facebook.com'
license 'All rights reserved'
description 'Provide an example to use as a template'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
# The version should always be '0.1.0', and you'll never ever change it.
version '0.1.0'

# If you use any of the CPE node functions, or cpe_remote, you'll need these
# in your metadata.
# Any cookbooks you depend on for any reason should be listed here.
depends 'cpe_remote'
depends 'cpe_utils'
