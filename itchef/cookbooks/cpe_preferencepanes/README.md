cpe_preferencepanes Cookbook
========================
Install a profile to manage access to preference panes. Suitable for preference
panes without macos built-in authorization hooks.

Requirements
------------
* macOS

Attributes
----------
* node['cpe_preferencepanes']['DisabledPreferencePanes']
* node['cpe_preferencepanes']['HiddenPreferencePanes']

Usage
-----
The profile will manage the `com.apple.systempreferences` preference domain.

The organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe. The profile will also use
whichever prefix is set in node['cpe_profiles']['prefix'], which defaults
to `com.facebook.chef`

Example usage;

```
# Disable Desktop & Screen Saver, Disable iCloud and Profiles panes.
node.default['cpe_preferencepanes']['DisabledPreferencePanes'] = [
    'com.apple.preference.desktopscreeneffect',
    'com.apple.preferences.icloud',
    'com.apple.preferences.configurationprofiles',
]

# Hide Startup Disk pane.
node.default['cpe_preferencepanes']['HiddenPreferencePanes'] = [
    'com.apple.preference.startupdisk',
]
```

CFBundleIdentifers are [documented on Apple's developer site](https://developer.apple.com/documentation/devicemanagement/systempreferences).
