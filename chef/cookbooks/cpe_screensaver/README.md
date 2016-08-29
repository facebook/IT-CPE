cpe_screensaver Cookbook
========================
Install a profile to manage screensaver settings.


Attributes
----------
* node['cpe_screensaver']
* node['cpe_screensaver']['idleTime']
* node['cpe_screensaver']['askForPassword']
* node['cpe_screensaver']['askForPasswordDelay']
* node['cpe_screensaver']['MESSAGE']
* node['cpe_screensaver']['SelectedFolderPath']
* node['cpe_screensaver']['styleKey']
* node['cpe_screensaver']['ShufflesPhotos']

Usage
-----
The profile will manage the `com.apple.Screensaver` preference domain.

The profile's organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe. The profile will also use
whichever prefix is set in node['cpe_profiles']['prefix'], which defaults to `com.facebook.chef`

The profile delivers a payload for the above keys in `node['cpe_screensaver']`.  The three provided values
have a sane default, which can be overridden in another recipe if desired. The remaining keys must use acceptable
values as list in the examples below.

For example, you could tweak the above values

    node.default['cpe_screensaver']['idleTime'] = 300
    node.default['cpe_screensaver']['askForPasswordDelay'] = 2
    node.default['cpe_screensaver']['MESSAGE'] = 'Authorised access only!'

    # Acceptable values: 1-National Geographic, 2-Aerial, 3-Cosmos,4-Nature Patterns
    # a custom path: '/Users/YOURUSERNAME/Pictures'
    # or a 3rd party saver 'FILENAME.saver' (path assumed /Library/Screen Savers/FILENAME.saver)
    node.default['cpe_screensaver']['SelectedFolderPath'] = 4-Nature Patterns

    # Acceptable (defaults to KenBurns) values: Floating, Flipup, Reflections, Origami, ShiftingTiles, SlidingPanels,
    # PhotoMobile, HolidayMobile, PhotoWall, VintagePrints, KenBurns, Classic
    node.default['cpe_screensaver']['styleKey']

    # Acceptable (defaults to 0) values: 0 or 1
    node.default['cpe_screensaver']['ShufflesPhotos'] = 0

Although you can manage the screensaver "module" via a profile, the UI doesn't get locked down. This could be misleading
to end users, they may think they can change it via the UI and will find out their settings keep getting mashed by the
profile. Consider a lockdown profile "DisabledPreferencePanes" to work in conjunction with this cookbook.

Also note the "Start after:" UI element is wildly inconsistent as it has fixed values (0,1,2,5,10,20,30,1 Hour) in the
drop down menu. If you set a value that is not listed in the UI, the os will honor your value, but the UI element will
not show it instead, defaulting to 20 Minutes. Another reason to consider a lockdown profile "DisabledPreferencePanes"
to work in conjunction with this cookbook.

Example using defaults command `defaults -currentHost write com.apple.screensaver idleTime 240`
