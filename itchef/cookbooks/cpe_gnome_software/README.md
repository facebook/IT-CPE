cpe_gnome_software coookbook
============================
Configures GNOME Software and PackageKit

Requirements
------------
* Fedora

Attributes
----------
* node['cpe_gnome_software']['manage']
* node['cpe_gnome_software']['gnome_software']['manage']
* node['cpe_gnome_software']['gnome_software'][KEY]
* node['cpe_gnome_software']['packagekit']['manage']
* node['cpe_gnome_software']['packagekit']['enable']

Usage
-----

Toggle the master `manage` switch on or off:

```
node.default['cpe_gnome_software']['manage'] = true
```

By default `gnome_software` and `packagekit` are managed once you enable the
master switch, they can be disabled:

```
node.default['cpe_gnome_software']['gnome_software']['manage'] = false
node.default['cpe_gnome_software']['packagekit']['manage'] = false
```

### Setting individual GNOME Software configuration
Any key defined in the schema for `org.gnome.software` can be configured
(except for the `timestamp` ones)

```
❯ gsettings list-keys org.gnome.software | sort
allow-updates
check-timestamp
compatible-projects
download-updates
enable-repos-dialog
enable-shell-extensions-repo
external-appstream-system-wide
external-appstream-urls
filter-default-branch
first-run
free-repos
free-repos-url
install-bundles-system-wide
installed-page-show-size
install-timestamp
nonfree-software-uri
official-repos
popular-overrides
prompt-for-nonfree
refresh-when-metered
review-karma-required
review-server
screenshot-cache-age-maximum
security-timestamp
show-folder-management
show-nonfree-prompt
show-nonfree-ui
show-ratings
show-upgrade-prerelease
upgrade-notification-timestamp
```

```
%w{
  allow-updates
  download-updates
}.each do |k|
  node.default['cpe_gnome_software']['gnome_software'][k] = false
end
```
