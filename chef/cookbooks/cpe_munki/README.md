cpe_munki Cookbook
==================
cpe_munki can install and configure Munki, remediate broken installs, and manage local-only manifests.

Requirements
------------
Mac OS X

Attributes
----------
* node['cpe_munki']['auto_remediate']
* node['cpe_munki']['configure']
* node['cpe_munki']['install']
* node['cpe_munki']['local']['managed_installs']
* node['cpe_munki']['local']['managed_uninstalls']
* node['cpe_munki']['local']['optional_installs']
* node['cpe_munki']['munki_version_to_install']
* node['cpe_munki']['preferences']

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
must be available in the node's catalogs**

**Add `managed_installs` using a local manifest**

    managed_installs = [
      'Firefox',
      'Chrome'
    ]
    managed_installs.each do |item|
      node.default['cpe_munki']['local']['managed_installs'] << item
    end

### Installing Munki
The 'cpe_munki_install' resource will install Munki. You must set the `install` attribute to be `true` in order to install the Munki packages:

  node.default['cpe_munki']['install'] = true

By default, Munki releases from Github come as a single distribution package, which contain the separate subpackages inside. You can separate out the component packages with `pkgutil`:

    $ /usr/sbin/pkgutil --expand munkitools-3.0.3.3333.pkg munkitools3

Munki will determine what packages to install by looping through all the keys in `node['cpe_munki']['munki_version_to_install']`. Each key should correspond to a hash that contains the version of the package, and its SHA256 checksum. To configure a client to install Munki 3 in its entirety:

    node.default['cpe_munki']['munki_version_to_install']['admin'] = {
      'version' => '3.0.0.3333',
      'checksum' =>
        '42fb19dbaa1d24691a596a3d60e900f57d2b9d6e1a8018972fe4c52c2f988682',
    }
    node.default['cpe_munki']['munki_version_to_install']['app'] = {
      'version' => '4.6.3330',
      'checksum' =>
      'f1354f99bececdabc0549531e50e1362a332a8e4802a07066e6bc0e74b72258d',
    }
    node.default['cpe_munki']['munki_version_to_install']['app_usage'] = {
      'version' => '3.0.0.3333',
      'checksum' =>
      'bc3299823d024982122de3d98905d28d6bf36585b060f7a0526a591c45815ad4',
    }
    node.default['cpe_munki']['munki_version_to_install']['core'] = {
      'version' => '3.0.0.3333',
      'checksum' =>
      'd82dd386d7aebe459314b7d62da993732e2b1e08813f305fab08ece10e2e330d',
    }
    node.default['cpe_munki']['munki_version_to_install']['launchd'] = {
      'version' => '3.0.3265',
      'checksum' =>
      'b3871f6bb3522ce5e46520bcab06aed2644bf11265653f6114a0e34911f17914',
    }

The `install` resource will loop through all the package names and use `cpe_remote` to download the package from `node['cpe_remote']['base_url']`, verify the checksum of the downloaded file matches, and then install it. You can override the URL on a per-package basis if you so wish:

    node.default['cpe_munki']['munki_version_to_install']['admin'] = {
      'version' => '3.0.0.3333',
      'url' => 'foo.com/path/to/munkitools_admin.pkg'
      'checksum' =>
        '42fb19dbaa1d24691a596a3d60e900f57d2b9d6e1a8018972fe4c52c2f988682',
}

You can also override the application name on a per-package basis if you so wish:

node.default['cpe_munki']['munki_version_to_install']['admin'] = {
  'version' => '3.0.0.3333',
  'app_name' => 'munkitools_admin'
  'checksum' =>
    '42fb19dbaa1d24691a596a3d60e900f57d2b9d6e1a8018972fe4c52c2f988682',
}

### Munki Configuration
The 'cpe_munki_config' resource will install a profile that configures Munki settings. You must set `node['cpe_munki']['config']` to be `true` for this to run.

By leveraging `cpe_profiles`, we can craft a profile that has the base settings we want to apply. The default settings are stored in `node['cpe_munki']['preferences']`. Those values can be overridden in any recipe to be applied as you want:

    # Munki attribute overrides
    {
      'DaysBetweenNotifications' => 90,
      'InstallAppleSoftwareUpdates' => true,
      'SoftwareRepoURL' =>
        "https://#{server}/repo"
    }.each do |k, v|
      node.default['cpe_munki']['preferences'][k] = v
    end

### Local Manifests
The 'cpe_munki_local' resource will implement a local-only manifest.

Local Munki is where items from the `node['cpe_munki']['local']['managed_installs']`, `node['cpe_munki']['local']['managed_uninstalls']` and `node['cpe_munki']['local']['optional_installs']` node attributes are added to a local manifest in the respective `managed_installs`, `managed_uninstalls` and `optional_installs` keys.  This allows any individual (or group, or node, etc.) to specify an existing optional install as either an install or uninstall.  Adding an item to either of these two attributes will combine with the existing client manifest.

If an item is removed from `managed_installs` or `managed_uninstalls` in this manner, Munki will no longer forcefully manage its installation or removal. If an item is added to `managed_uninstalls`, it is also removed from the 'managed_installs' array of the SelfServeManifest if the item exists there.

Support for `optional_installs` requires Munki v3.3 or later.

The default list of items to be installed on clients is in cpe_munki::managed_installs. Anyone can override this value to add or remove things that they want (or don't want).


    # How to install one App:
    node.default['cpe_munki']['local']['managed_installs'] << 'Firefox'

    # How to install a list of Apps:
    [
      'Firefox',
      'GoogleChrome',
      'Atom',
      'Dropbox',
    ].each do |item|
      node.default['cpe_munki']['local']['managed_installs'] << item
    end


### Auto Remediation
This cookbook can also attempt to remediate broken Munki installs.

Set `node['cpe_munki']['auto_remediate']` to the amount of days Chef should allow Munki to not run before reinstalling all packages. Chef will read the /Library/Preferences/ManagedInstalls preferences domain to parse the `LastCheckDate` key. If that key is older than the number of days specified, all package receipts are forgotten and Chef will reinstall the Munki packages.

    node.default['cpe_munki']['auto_remediate'] = 30
