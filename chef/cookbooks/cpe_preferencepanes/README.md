cpe_preferencepanes Cookbook
========================
Install a profile to manage access to preference panes. Suitable for preference
panes without macos built-in authorization hooks.


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

CFBundleIdentifers currently present in El-Capitan;

	com.apple.preferences.users
	com.apple.preferences.appstore
	com.apple.preference.general
	com.apple.preferences.Bluetooth
	com.apple.preference.datetime
	com.apple.preference.desktopscreeneffect
	com.apple.preference.digihub.discs
	com.apple.preference.displays
	com.apple.preference.dock
	com.apple.preference.energysaver
	com.apple.preference.expose
	com.apple.preferences.extensions
	com.apple.prefpanel.fibrechannel
	com.apple.preference.ink
	com.apple.preferences.internetaccounts
	com.apple.preference.keyboard
	com.apple.Localization
	com.apple.preference.mouse
	com.apple.preference.network
	com.apple.preference.notifications
	com.apple.preferences.parentalcontrols
	com.apple.preference.printfax
	com.apple.preference.printfax
	com.apple.preferences.configurationprofiles
	com.apple.preference.security
	com.apple.preferences.sharing
	com.apple.preference.sound
	com.apple.preference.speech
	com.apple.preference.spotlight
	com.apple.preference.startupdisk
	com.apple.prefs.backup
	com.apple.preference.trackpad
	com.apple.preference.universalaccess
	com.apple.preferences.icloud

CFBundleIdentifers for 3rd parties can also be included;

	com.oracle.java.JavaControlPanel
