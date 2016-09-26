cpe_spotlight Cookbook
=========================
Adds or removes exclusions to Spotlight indexing.

Adding a path to the `exclusions` list will disable Spotlight indexing for that path, and Spotlight will not search its contents.  This is equivalent to adding a path to the "Privacy" section of the Spotlight pane in the System Preferences.

Removing a path from that list will remove the exclusion.  Spotlight will re-index that path on its normal schedule (which may result in excess CPU and disk usage while it builds the index).  

This will not affect Privacy settings that were manually added via the System Preferences' Spotlight pane.

Requirements
------------
Mac OS X

Attributes
----------
node['cpe_spotlight']['exclusions']
  # Adding a path to this list will add it to the Spotlight exclusion list. This has the side-effect of also removing it from the Spotlight index immediately.
  # Values: An array of paths

Usage
-----
#### cpe_spotlight::default

To add or remove Spotlight exclusions, you just need to add entries to the `exclusions` list.

Example: 
`node.default['cpe_spotlight']['exclusions'] << '/Users/nmcspadden/Desktop/test1'`

To remove something that was previously added to the Spotlight privacy exclusions, remove it from the list.  If an item was previously in the list but is no longer present, it will be removed as an exclusion.

It is not possible to remove an existing Spotlight exclusion that was manually added via the System Preferences with this cookbook.
