cpe_symlinks Coobook
====================
Manages symlinks on the machine

Requirements
------------
macOS, Linux

Attributes
----------
* node['cpe_symlinks']

Usage
-----
This recipe manages symlinks.

Add any arbitrary symlinks and original paths as a key/value pair in a hash
containing the desired directory in `node['cpe_symlinks']` to have them managed.
As long as the values are not nil and the file paths exist, this cookbook will
manage them.

```
# Add symlink to `/usr/local/bin`
{
  'chef-apply'  => '/opt/chef/bin/chef-apply',
  'chef-client' => '/opt/chef/bin/chef-client',
  'chef-shell'  => '/opt/chef/bin/chef-shell',
  'chef-solo'   => '/opt/chef/bin/chef-solo',
  'ohai'        => '/opt/chef/bin/ohai',
  'knife'       => '/opt/chef/bin/knife',
  'chefctl'     => '/opt/facebook/ops/scripts/chef/chefctl.sh',
}.each { |k, v| node.default['cpe_symlinks']['/usr/local/bin'][k] = v }

# Add symlink(s) to `/opt/foo/bin`
{
  'subl' => '/Applications/Sublime Text 3.app/something/sublime',
}.each { |k, v| node.default['cpe_symlinks']['/opt/foo/bin'][k] = v }
```
