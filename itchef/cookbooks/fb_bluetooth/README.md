fb_bluetooth Cookbook
=========================
Install a profile to manage Bluetooth settings. This should only apply to
Dashboards, Lobbies, Imaging servers, and Wayfinders.

Requirements
------------
Mac OS X

Attributes
----------
* node['fb_bluetooth']
* node['fb_bluetooth']['BluetoothAutoSeekKeyboard']
* node['fb_bluetooth']['BluetoothAutoSeekPointingDevice']

Usage
-----
The profile will manage the `com.apple.Bluetooth` preference domain.

The profile's organization key defaults to `Facebook` unless
`node['organization']` is configured in your company's custom init recipe. The
profile will also use whichever prefix is set in node['cpe_profiles']['prefix'],
which defaults to `com.facebook.chef`

The profile delivers a payload of all keys in `node['fb_bluetooth']` that are
non-nil values.  The two provided keys
`node['fb_bluetooth']['BluetoothAutoSeekKeyboard']` and
`node['fb_bluetooth']['BluetoothAutoSeekPointingDevice']` are nil, so that no
profile is installed by default.

You can add any arbitrary keys to `node['fb_bluetooth']` to have them added to
your profile.  As long as the values are not nil and create a valid profile,
this cookbook will install and manage them.

The most common use case is for service machines.  Service devices like
dashboards will want to suppress the automatic
"Search for Bluetooth mouse / keyboard" prompt that comes up when no USB
keyboard is plugged in:

```
# Disable Bluetooth
node.default['fb_bluetooth']['BluetoothAutoSeekKeyboard'] = 0
node.default['fb_bluetooth']['BluetoothAutoSeekPointingDevice'] = 0
```
