#!/usr/bin/python
"""
Adds Internet Plug-Ins to the Application Inventory data that is gathered
by munki.
Thanks to Adam Reed and Josh Malone
"""

import os
import sys

sys.path.insert(0,'/usr/local/munki')

from munkilib import FoundationPlist

invPath = r"/Library/Managed Installs/ApplicationInventory.plist"
plugins = r"/Library/Internet Plug-Ins/"
directoryListing = os.listdir(plugins)
appinv = FoundationPlist.readPlist(invPath)

print "Adding %i plugins" % len(directoryListing)

for x in directoryListing:
    path = os.path.join(plugins, x, 'Contents/Info.plist')
    try:
        info = FoundationPlist.readPlist(path)
        plugin = {}
        plugin['CFBundleName'] = info.get('CFBundleName', x)
        plugin['bundleid'] = info.get('CFBundleIdentifier', 'N/A')
        plugin['version'] = info.get('CFBundleVersion','N/A')
        plugin['path'] = os.path.join(plugins, x)
        plugin['name'] = info.get('CFBundleName', os.path.splitext(os.path.basename(x))[0])
        appinv.append(plugin.copy())
    except Exception, message:
        pass

FoundationPlist.writePlist(appinv, invPath)
exit(0)