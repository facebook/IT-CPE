cpe_chocolatey Cookbook
=============================
This is a cookbook that will install chocolatey and setup a
scheduled task to run every 30min to update/install required packages.

Requirements
------------
* Windows cookbook - https://github.com/chef-cookbooks/windows
* Chef_Handler cookbook - https://github.com/chef-cookbooks/chef_handler

Windows OS

Attributes
----------

* node['cpe_chocolatey']['dir']
* node['cpe_chocolatey']['config_dir']
* node['cpe_chocolatey']['config']
* node['cpe_chocolatey']['run']
* node['cpe_chocolatey']['app_cache']
* node['cpe_chocolatey']['default_feed']

Usage
-----
Include this recipe and tweak the package list based on any nuget
feed you may use. By default, it points to the public chocolatey repository.

**Steps:**
* Install latest chocolatey from chocolatey.org.
* Drop the configuration files into the chocolatey install `config` directory.
* Add Windows task within `Scheduled Tasks` to run at interval set.
* 30 minutes after Chef has ran, packages will start installing.

**Tweak Windows Task Interval:**

Edit the `chocolatey_configure.rb` file under the `windows_task` resource.

This integer is based on minutes, 30 = 30 minutes: `frequency_modifier 30`

**Add additional nuget feed to your list for use:**

Add an additional attribute within `attributes/default.rb`.

Example:

```
default['cpe_chocolatey']['default_feed'] = 'https://chocolatey.org/api/v2/'
default['cpe_chocolatey']['mycompany_feed'] = 'https://yourwebsite.com/nuget/feed'
```

Usage:
```
choco_managed_installs['pkg_name'] = {
  'name' => 'pkg_name',
  'version' => 'pkg_version',
  'feed' => node['cpe_chocolatey']['default_feed'],
}
```

Remember, pkg_name/pkg_version needs to be replaced with the name and package version
that you would like to install/update.

**Add additional package to list:**

Add an additional package to the `chocolatey_required_apps.rb`.

Example:
```
choco_managed_installs['pkg_name'] = {
  'name' => 'pkg_name',
  'version' => 'pkg_version',
  'feed' => node['cpe_chocolatey']['default_feed'],
}
```

Remember, pkg_name/pkg_version needs to be replaced with the name and package version
that you would like to install/update.
