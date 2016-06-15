cpe_screensaver Cookbook
========================
Install a profile to manage screensaver settings.


Attributes
----------
* node['cpe_screensaver']
* node['cpe_screensaver']['idleTime']
* node['cpe_screensaver']['askForPassword']
* node['cpe_screensaver']['askForPasswordDelay']

Usage
-----
The profile will manage the `com.apple.Screensaver` preference domain.

The profile's organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe.

The profile delivers a payload for the above keys in `node['cpe_screensaver']`.  The three provided have a sane default, which can be overridden in another recipe if desired.

For example, you could tweak the above values

    node.default['cpe_screensaver']['idleTime'] = 300
    node.default['cpe_screensaver']['askForPasswordDelay'] = 2
