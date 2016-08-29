cpe_desktop Cookbook
========================
Install a profile to lock a specific desktop wallpaper on a given machine. This
cookbook is suitable for devices placed in a public space, or devices requiring
organisational branding.


Attributes
----------
* node['cpe_desktop']['override-picture-path']

Usage
-----
The profile delivers a payload for the above key in the `node['cpe_desktop']`.

The organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe. The profile will also use
whichever prefix is set in node['cpe_profiles']['prefix'], which defaults
to `com.facebook.chef`

For example, you could tweak the above value:

    node.default['cpe_desktop']['override-picture-path'] = '/opt/org/pic.jpg'

Although the wallpaper is locked using this profile, the UI doesn't get locked
down. This could be misleading to the end user, they may think they
can change it via the UI by accessing the preference pane. Consider a lockdown
profile "DisabledPreferencePanes" to work in conjunction with this cookbook.
