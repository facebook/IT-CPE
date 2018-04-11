cpe_deprecation_notifier Cookbook
=========================
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

To update version of Deprecation Notifier:
  - Update version # and checksum

Use the attributes to enable/disable or tweak any of the settings for
Deprecation Notifier.

Example:
  node.default['cpe_deprecation_notifier']['enable'] = true
    - Enables Deprecation Notifier.

  node.default['cpe_deprecation_notifier']['expected_version'] = '10.12.6'
  - Updates 'expected version' to the version of macOS you are enforcing
    to 10.12.6.

  node.default['cpe_deprecation_notifier']['instruction_url'] = 'munki://detail-macOSComboUpdater10.12.6'
  - Points instruction_url to  to the correct file in MSC.
