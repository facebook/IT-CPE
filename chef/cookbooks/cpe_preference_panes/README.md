cpe_preference_panes Cookbook
=========================
Install a profile to manage Blacklisting PreferencePanes.

Requirements
------------
Mac OS X

Attributes
----------
* node['cpe_preference_panes']['DisabledPreferencePanes']
* node['cpe_preference_panes']['HiddenPreferencePanes']

Usage
-----
The profile will manage the `com.apple.systempreferences` preference domain. 

The profile's organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe. The profile will also use
whichever prefix is set in node['cpe_profiles']['prefix'], which defaults to `com.facebook.chef`

The profile delivers a payload of arrays that are non-nil values.  The two provided keys `node['cpe_preference_panes']['DisabledPreferencePanes']` and `node['cpe_preference_panes']['HiddenPreferencePanes']` are nil, so that no profile is installed by default.

You can add any arbitrary keys to `node['cpe_preference_panes']` to have them added to your profile.  As long as the values are not nil and create a valid profile, this cookbook will install and manage them.

The most common use case is to disable certain Preference Panes that have no built-in admin authorization such as the Desktop & ScreenSaver Pane.

    # Disable and Hide Desktop & ScreenSaver
    node.default['cpe_preference_panes']['DisabledPreferencePanes'] = ["com.apple.preference.desktopscreeneffect"]
	node.default['cpe_preference_panes']['HiddenPreferencePanes'] = ["com.apple.preference.desktopscreeneffect"]
