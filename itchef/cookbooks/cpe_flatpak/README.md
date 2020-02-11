cpe_flatpak Cookbook
====================
This cookbook creates resources to manage flatpaks

Requirements
------------
* cpe_helpers

Attributes
----------
* node['cpe_flatpak']
* node['cpe_flatpak']['ignore_failure']
* node['cpe_flatpak']['manage']
* node['cpe_flatpak']['remotes']
* node['cpe_flatpak']['pkgs']

Usage
-----

### cpe_flatpak
Will add any new repos defined in remotes, add any new packages defined
in pkgs, and remove any repos that are not in remotes and any packages
that are not in pkgs.
It will also install flatpak if it's not installed on the system and keep
it up to date.

### Manage

```
node.default['cpe_flatpak']['ignore_failure'] = false
node.default['cpe_flatpak']['manage'] = true
node.default['cpe_flatpak']['remotes']['remote_name'] = "URL"
node.default['cpe_flatpak']['pkgs']['pkg_name'] = "remote_name"
```

Add new Flatpak remote repos by extending the remotes hash. The "flathub"
repo is installed by default. You can see a list of more repos at
<https://gist.github.com/intika/8e4a7faeb72c3a393e42ac9af85b62b7>.
e.g. To add the KDE repository

```
node.default['cpe_flatpak']['remotes']['kde'] =
  "https://distribute.kde.org/kdeapps.flatpakrepo"
```

*NOTE* Make sure that the remote name that you assign here matches the name
that the repo sets in flatpak when it installs. Run
'flatpak remotes -d' after a test install to see what name the repo sets.

To add additional packages, extend the pkgs hash similarly. The remote_name
is the name used in the remotes hash.
e.g. To add the Spotify client

```
node.default['cpe_flatpak']['pkgs']['com.spotify.Client'] = 'flathub'
```

By default any failure invoking the `flatpak` tool will cause `cpe_flatpak` to
fail; override by setting the `ignore_failure` attribute to `true` to avoid
remote operation errors from causing Chef to fail.
