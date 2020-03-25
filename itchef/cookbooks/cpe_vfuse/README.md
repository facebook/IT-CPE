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
* node['cpe_vfuse']['pkg']['checksum']
* node['cpe_vfuse']['pkg']['receipt']
* node['cpe_vfuse']['pkg']['version']
* node['cpe_vfuse']['pkg']['pkg_name']
* node['cpe_vfuse']['pkg']['pkg_url']

Usage
-----

`node['cpe_vfuse']['install']` declares whether to install `vfuse`. The default
setting is `false`.

`node['cpe_vfuse']['configure']` declares whether to confiture `vfuse` templates.
The default setting is `false`.

`node['cpe_vfuse']['templates']` is an array which will create and manage
template[s].

You can add any arbitrary templates to have them available to `vfuse`.
As long as the values are not nil and create valid templates, this cookbook
will create and manage them.

Add `'static' => true,` if you don't want the template to be overwritten after
initially created.

```
  # Add custom template
  [
    {
      'output_name' => 'bootstrap',
      'source_dmg' =>
        "https://#{node['distro_server']}/restor/images/bootstrap.dmg",
      'checksum' =>
        'a8d8b26ed3d0bc45bf7993e1a25f4e6fe89ae95c5818f8470b4803f0bee74b2a',
      'cache' => true,
      'snapshot' => true,
      'serial_number' => 'VMbootstrap',
      'static' => false,
    },
  ].each { |template| node.default['cpe_vfuse']['templates'] << template }
```
