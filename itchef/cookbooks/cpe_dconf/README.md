cpe_dconf Cookbook
==================
This cookbook manages dconf configuration.

Requirements
------------
* Linux (tested on Fedora, Ubuntu/Debian and Arch)

Attributes
----------
* node['cpe_dconf']['settings']

Usage
-----
Each component provides a name and a hash of keys to set. The hash is added to
`node['cpe_dconf']['settings']`. In the dconf architecture, settings are
organized into directories. The provided hash should follow this same structure;
see the examples for how to do this. Make sure not to have a leading slash in
the directory names.

Note that you can specify key values in two ways: the value can be given as a
hash that indicates the value and the lock status, or as a convenience, you can
give the value as a literal, and `'lock' => true` will be assumed.

### Examples

#### Screensaver example

```
node['cpe_dconf']['settings']['screensaver'] = {
  'org/gnome/desktop/screensaver' => {
    'lock-enabled' => 'true',
    'lock-delay' => {
      'value' => 'uint32 0',
      'lock' => false,
    },
  }.
  'org/gnome/desktop/session' => {
    'idle-delay' => 'uint32 600'
  }
}
```
