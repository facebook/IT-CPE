cpe_deprecation_notifier Cookbook
=================================
This cookbook is used to configure Deprecation Notifier.

Requirements
------------
macOS

Attributes
----------
* node['cpe_deprecation_notifier']['enable']
* node['cpe_deprecation_notifier']['path']
* node['cpe_deprecation_notifier']['pkg_reciept']
* node['cpe_deprecation_notifier']['checksum']
* node['cpe_deprecation_notifier']['expected_version']
* node['cpe_deprecation_notifier']['instruction_url']
* node['cpe_deprecation_notifier']['deprecation_msg']
* node['cpe_deprecation_notifier']['initial_timeout']
* node['cpe_deprecation_notifier']['maxwindow_timeout']
* node['cpe_deprecation_notifier']['timeout_multiplier']
* node['cpe_deprecation_notifier']['renotify_period']

Usage
-----
This cookbook manages the settings for Deprecation Notifier.

Use the attributes to enable/disable or tweak any of the settings for
Deprecation Notifier.

Examples
--------
Define version to install:

```
{
  'pkg_reciept' => 'com.CPE.deprecationnotifier',
  'version' => '3.0',
  'checksum' =>
    '80787625f7606113c10f8af55a67c0a2cfbfd2ab34c7e7ccd1789f27785289d4',
}.each { |k, v| node.default['cpe_deprecation_notifier'][k] = v }
```

Enable Deprecation Notifier:

```
node.default['cpe_deprecation_notifier']['enable'] = true
```

Update `expected version` to the version of macOS you are enforcing to 10.12.6:

```
node.default['cpe_deprecation_notifier']['expected_version'] = '10.12.6'
```

Point instruction_url to the correct file in MSC:

```
node.default['cpe_deprecation_notifier']['instruction_url'] = 'munki://detail-macOSComboUpdater10.12.6'
```
