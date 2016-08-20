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

The profile organization key defaults to `Facebook` unless `node['organization']`
is configured in your company's custom init recipe. The profile will also use
whichever prefix is set in node['cpe_profiles']['prefix'], which defaults to
`com.facebook.chef`

The profile delivers a payload for the above keys in `node['cpe_screensaver']`.
The provided "security" keys have a sane default, which can be overridden in
another recipe if desired.

For example, you could tweak the above values

    node.default['cpe_screensaver']['idleTime'] = 300
    node.default['cpe_screensaver']['askForPasswordDelay'] = 2
    node.default['cpe_screensaver']['MESSAGE'] = 'Authorised access only!'

    # Acceptable (defaults to KenBurns) values: Floating, Flipup, Reflections,
    # Origami, ShiftingTiles, SlidingPanels, PhotoMobile, HolidayMobile,
    # PhotoWall, VintagePrints, KenBurns, Classic
    node.default['cpe_screensaver']['styleKey']

    # Acceptable values: 1-National Geographic, 2-Aerial, 3-Cosmos,
    # 4-Nature Patterns or a custom path: '/Users/YOURUSERNAME/Pictures'
    node.default['cpe_screensaver']['SelectedFolderPath'] = 4-Nature Patterns

    # Acceptable (defaults to 0) values: 0 or 1
    node.default['cpe_screensaver']['ShufflesPhotos'] = 0

Although you can manage the screensaver "module" via a profile, the UI doesn't
get locked down. This could be misleading to the end user, they may think they
can change it via the UI and will find out their settings keep getting mashed
by the profile. Consider a lockdown profile "DisabledPreferencePanes" to
work in conjuntion with this cookbook.

