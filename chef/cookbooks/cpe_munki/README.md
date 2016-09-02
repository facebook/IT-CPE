cpe_munki Cookbook
==================
cpe_munki is an umbrella cookbook to install & configure Munki and manage local-only manifests.  Munki can be installed, configured, and/or locally managed with this cookbook.

Requirements
------------
Mac OS X

Attributes
----------
* node['cpe_munki']['munki_version_to_install']
* node['cpe_munki'][version]
* node['cpe_munki']['preferences']
* node['cpe_munki']['local']['managed_installs']
* node['cpe_munki']['local']['managed_uninstalls']

Usage
-----
This cookbook handles the various aspects of a Munki install. To use this cookbook,
set the attributes according to what you want to do and the cookbook will handle the rest.

Examples:

**Install Munki and do nothing else**

    node.default['cpe_munki']['install']  = true

**Install and configure Munki**

    node.default['cpe_munki']['install'] = true
    node.default['cpe_munki']['configure'] = true
    node.default['cpe_munki']['preferences']['SoftwareRepoURL'] =
      'https://munki.MYCOMPANY.com/repo'
    node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] =
      true

**Only configure Munki**

    node.default['cpe_munki']['configure'] = true
    node.default['cpe_munki']['preferences']['SoftwareRepoURL'] =
      'https://munki.MYCOMPANY.com/repo'
    node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] =
      true
    node.default['cpe_munki']['preferences']['AppleSoftwareUpdatesOnly'] =
      true

Advanced Example:

**Note: You must have a Munki server setup and all packages you add to this attribute
must be available in the node's Munki catalog**

**Add `managed_installs` using a local manifest**

    managed_installs = [
      'Firefox',
      'Chrome'
    ]
    managed_installs.each do |item|
      node.default['cpe_munki']['local']['managed_installs'] << item
    end

### Installing Munki
The munkitools2.chef AutoPkg recipe will separate the Munki metapackage into the App package (which is left alone as a cpe_remote_pkg install, because it contains binaries), and all the admin, core, and launchd files.

The `files` directory contains the 'admin', 'core', and 'launchd' folders, which each contain a folder with a version name. Within each version directory are the files from that version's package. So `admin` -> `2.7.0.2753` contains all the files installed by the "munkitools-admin" version 2.7.0.2753 package.

THe `attributes` directory contains the generic default attributes used across the recipe, along with a file that matches the version name that you want to install. This versioned attributes file contains a list of all files that will be installed by 'admin', 'core', and 'launchd', along with the version of the app package and the SHA256 hash for the package.  Each included Munki version is added to an attribute:
`node['cpe_munki'][2.7.0.273]`.

Both the files and attributes here are created by munkitools2.chef.

This allows different versions of Munki to be installed on different clients. `node['cpe_munki']['munki_version_to_install']` is what will be installed when `cpe_munki::install_munki` runs on a client.

This is done by `cpe_munki::install`.

#### Installing different versions of Munki
The default attributes file contains the logic for assigning the version to be installed. By default, `node['cpe_munki']['munki_version_to_install']` will be installed.  You can split up versions according any logic you want.  Example:

    default['cpe']['munki']['munki_version_to_install'] = '2.6.1.2684'
    # define this to be whatever criteria you want
    # this example uses a fictional username variable to see if it's in this list of users
    testers = [name1, name2, name3].include?(username)
    if testers
      default['cpe']['munki']['munki_version_to_install'] = '2.7.0.2753'
    end

The above example shows how to install a newer version of Munki into a special group of testers based on some criteria (made up, in this case), whereas everyone else would get an older version.

### Munki Configuration
By leveraging cpe_profiles, we can craft a profile that has the base settings we want to apply to all clients. The default settings are stored in `node['cpe_munki']['preferences']`.  Those values can be overridden in any recipe to be applied as you want:

    # Munki attribute overrides
    {
      'DaysBetweenNotifications' => 90,
      'InstallAppleSoftwareUpdates' => true,
      'SoftwareRepoURL' =>
        "https://#{server}/repo"
    }.each do |k, v|
      node.default['cpe_munki']['preferences'][k] = v
    end

This is done in `cpe_munki::config`.

### Local Manifests
Local Munki is where items from the `node['cpe_munki']['local']['managed_installs']` and `node['cpe_munki']['local']['managed_uninstalls']` node attributes are added to a local manifest in the respective `managed_installs` and `managed_uninstalls` keys.  This allows any individual (or group, or node, etc.) to specify an existing optional install as either an install or uninstall.  Adding an item to either of these two attributes will combine with the existing client manifest.

If an item is removed from `managed_installs` or `managed_uninstalls` in this manner, Munki will no longer forcefully manage its installation or removal. The item in question will resume its place as an optional install, and will not apply further updates or attempts to remove unless the user chooses to do so via Managed Software Center (or by re-adding it to these attributes).

The default list of items to be installed on clients is in cpe_munki::managed_installs. Anyone can override this value to add or remove things that they want (or don't want).

This is done by `cpe_munki::local`.
