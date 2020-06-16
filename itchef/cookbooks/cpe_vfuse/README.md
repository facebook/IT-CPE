cpe_vfuse Cookbook
==================
vfuse is a python script used to convert DMGs to VMDKs

Requirements
------------
macOS

Attributes
----------
* node['cpe_vfuse']
* node['cpe_vfuse']['configure']
* node['cpe_vfuse']['install']
* node['cpe_vfuse']['uninstall']
* node['cpe_vfuse']['templates']
* node['cpe_vfuse']['pkg']
* node['cpe_vfuse']['pkg']['name']
* node['cpe_vfuse']['pkg']['allow_downgrade']
* node['cpe_vfuse']['pkg']['checksum']
* node['cpe_vfuse']['pkg']['receipt']
* node['cpe_vfuse']['pkg']['version']
* node['cpe_vfuse']['pkg']['pkg_name']
* node['cpe_vfuse']['pkg']['pkg_url']

Usage
-----

`node['cpe_vfuse']['install']` declares whether to install `vfuse`. The default
setting is `false`.

`node['cpe_vfuse']['configure']` declares whether to configure `vfuse` templates
and the vfuse `config.json` file. The default setting is `false`.

`node['cpe_vfuse']['templates']` is a hash which will create and manage
template[s]. Please note that if the template path's *parent* directory does not
exist, you will need to create it prior to `cpe_vfuse` running.

You can add any arbitrary templates to have them available to `vfuse`.
As long as the values are not nil and create valid templates, this cookbook
will create and manage them.

Add `'static' => true,` if you don't want the template to be overwritten after
initially created.

```
  # Add custom template
  node.default['cpe_vfuse']['templates']['bootstrap'] = {
    'cache' => true,
    'checksum' =>
      'a8d8b26ed3d0bc45bf7993e1a25f4e6fe89ae95c5818f8470b4803f0bee74b2a',
    'serial_number' => 'VMbootstrap'
    'source_dmg' =>
      'https://#{node['distro_server']}/restor/images/bootstrap.dmg',
    'snapshot' => true,
    'static' => false,
  }
```

If you want to override the serial number (say for DEP testing), you can then
use `cpe_user_customizations` to inject it.

```
# Apply serial number to every template
node['cpe_vfuse']['templates'].each_key do |k|
  node.default['cpe_vfuse']['templates'][k]['serial_number'] = 'DEP_Serial'
end
```
