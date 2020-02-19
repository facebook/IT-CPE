cpe_munki Cookbook
==================
cpe_munki can install and configure Munki, remediate broken installs, and manage
local-only manifests.

Requirements
------------
* macOS

Attributes
----------
* node['cpe_munki']['auto_remediate']
* node['cpe_munki']['configure']
* node['cpe_munki']['install']
* node['cpe_munki']['skip_enforcing_launchds']
* node['cpe_munki']['local']['managed_installs']
* node['cpe_munki']['local']['managed_uninstalls']
* node['cpe_munki']['local']['optional_installs']
* node['cpe_munki']['munki_version_to_install']
* node['cpe_munki']['preferences']

Usage
-----
This cookbook handles the various aspects of a Munki install. To use this
cookbook, set the attributes according to what you want to do and the cookbook
will handle the rest.

Examples:

### Install Munki and do nothing else

```
    node.default['cpe_munki']['install']  = true
```

### Install and configure Munki

```
node.default['cpe_munki']['install'] = true
node.default['cpe_munki']['configure'] = true
node.default['cpe_munki']['preferences']['SoftwareRepoURL'] =
  'https://munki.MYCOMPANY.com/repo'
node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] = true
```

### Only configure Munki

```
node.default['cpe_munki']['configure'] = true
node.default['cpe_munki']['preferences']['SoftwareRepoURL'] = https://munki.MYCOMPANY.com/repo'
node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] = true
node.default['cpe_munki']['preferences']['AppleSoftwareUpdatesOnly'] = true
```

Advanced Example:

Note: You must have a Munki server setup and all packages you add to this
attribute must be available in the node's catalogs

#### Add `managed_installs` using a local manifest

```ruby
managed_installs = [
  'Firefox',
  'Chrome'
]
managed_installs.each do |item|
  node.default['cpe_munki']['local']['managed_installs'] << item
end
```

#### Add `optional_installs` using a local manifest

```ruby
optional_installs = [
  'Dropbox'
]
optional_installs.each do |item|
  node.default['cpe_munki']['local']['optional_installs'] << item
end
```

### Installing Munki
The 'cpe_munki_install' resource will install Munki. You must set the `install`
attribute to be `true` in order to install the Munki packages:

  node.default['cpe_munki']['install'] = true

By default, Munki releases from Github come as a single distribution package,
which contain the separate subpackages inside. You can separate out the component
packages with `pkgutil`:

```
/usr/sbin/pkgutil --expand munkitools-3.0.3.3333.pkg munkitools3
```

Munki will determine what packages to install by looping through all the keys in
 `node['cpe_munki']['munki_version_to_install']`.
Each key should correspond to a hash that contains the version of the package,
and its SHA256 checksum. To configure a client to install Munki 3 in its entirety:

```ruby
    {
      'launchd' => {
        'version' => '3.0.3265',
        'checksum' =>
        'b3871f6bb3522ce5e46520bcab06aed2644bf11265653f6114a0e34911f17914',
      },
      'admin' => {
        'version' => '3.2.0.3476',
        'checksum' =>
          '863614a59ba8ee4cb5730ff708fbdcb9fa4c248b456802fce28303ad9e312c17',
      },
      'app' => {
        'version' => '4.7.3445',
        'checksum' =>
          '50e946983a48a33a62c4e6115875500af1d2a46254415946f90bcc121c577816',
      },
      'app_usage' => {
        'version' => '3.2.0.3476',
        'checksum' =>
          '62c9e2238bde906c968203e09088d4dcb4bb0e82d9c9d7683b3f8024263e79ef',
      },
      'core' => {
        'version' => '3.2.0.3476',
        'checksum' =>
          '5319e29efb89f6c5b97c6976772da564f9c4781b802c582a895feb32678c83a8',
      },
    }.each do |k, v|
      node.default['cpe_munki']['munki_version_to_install'][k] = v
    end
```

The `install` resource will loop through all the package names and use `cpe_remote`
to download the package from `node['cpe_remote']['base_url']`, verify the checksum
of the downloaded file matches, and then install it. You can override the URL on
a per-package basis if you so wish:

```ruby
node.default['cpe_munki']['munki_version_to_install']['admin'] = {
  'version' => '3.0.0.3333',
  'url' => 'foo.com/path/to/munkitools_admin.pkg'
  'checksum' => '42fb19dbaa1d24691a596a3d60e900f57d2b9d6e1a8018972fe4c52c2f988682',
}
```

### Selectively enforcing Munki LaunchDaemons

By default, all Munki launch daemons and launch agents are loaded and enforced
every Chef run. If you want to stop enforcing any specific launch daemons/agents,
you can add the name after the prefix to the
`node['cpe_munki']['skip_enforcing_launchds']` array.

Since all Munki launch daemons/agents share the same prefix of "com.googlecode.munki",
you only need to add the last portion to this list. For example, you could use
this to prevent Chef from enforcing that the logout helper launch daemon is loaded:

```
node.default['cpe_munki']['skip_enforcing_launchds'] += ['logouthelper']
```

### Munki Configuration
The 'cpe_munki_config' resource will install a profile that configures Munki settings.
You must set `node['cpe_munki']['config']` to be `true` for this to run.

By leveraging `cpe_profiles`, we can craft a profile that has the base settings
we want to apply. The default settings are stored in `node['cpe_munki']['preferences']`.
Those values can be overridden in any recipe to be applied as you want:

```ruby
# Munki attribute overrides
{
  'DaysBetweenNotifications' => 90,
  'InstallAppleSoftwareUpdates' => true,
  'SoftwareRepoURL' => "https://#{server}/repo"
}.each do |k, v|
  node.default['cpe_munki']['preferences'][k] = v
end
```

### Local Manifests
The 'cpe_munki_local' resource will implement a local-only manifest.

Local Munki is where items from the `node['cpe_munki']['local']['managed_installs']`
and `node['cpe_munki']['local']['managed_uninstalls']` node attributes are added
to a local manifest in the respective `managed_installs` and `managed_uninstalls`
keys.  This allows any individual (or group, or node, etc.) to specify an existing
optional install as either an install or uninstall.  Adding an item to either of
these two attributes will combine with the existing client manifest.

If an item is removed from `managed_installs` or `managed_uninstalls` in this
manner, Munki will no longer forcefully manage its installation or removal.
If an item is added to `managed_uninstalls`, it is also removed from the
'managed_installs' array of the SelfServeManifest if the item exists there.

The default list of items to be installed on clients is in
`cpe_munki::managed_installs`. Anyone can override this value to add or remove
things that they want (or don't want).

```ruby
# How to install one App:
node.default['cpe_munki']['local']['managed_installs'] << 'Firefox'
```

```ruby
# How to install a list of Apps:
    [
      'Firefox',
      'GoogleChrome',
      'Atom',
      'Dropbox',
    ].each do |item|
      node.default['cpe_munki']['local']['managed_installs'] << item
    end
```

### Auto Remediation
This cookbook can also attempt to remediate broken Munki installs.

Set `node['cpe_munki']['auto_remediate']` to the amount of days Chef should
allow Munki to not run before reinstalling all packages. Chef will read the
/Library/Preferences/ManagedInstalls preferences domain to parse the
`LastCheckDate` key. If that key is older than the number of days specified, all
package receipts are forgotten and Chef will reinstall the Munki packages.

```
node.default['cpe_munki']['auto_remediate'] = 30
```
