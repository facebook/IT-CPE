cpe_safari Cookbook
============================
Configures any custom settings on Safari for Mac OS X.

For Safari, policies can be found here:
https://support.apple.com/en-us/HT202947

Requirements
------------
Mac OS X

Usage
-----
#### cpe_safari::default
  * Manages all aspects of the Safari browser for Mac OS X

Attributes
----------

`node['cpe_safari']` contains a hash of all the settings.

The profile's organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe. The profile will also use
whichever prefix is set in node['cpe_profiles']['prefix'], which defaults to `com.facebook.chef`

To provide your own custom setting, add the key you wish to manage to the hash:

`node.default['cpe_safari']['HomePage'] = 'http://www.facebook.com'`

You can see keys that can be managed by looking at the preferences domain:
`defaults read com.apple.safari`
