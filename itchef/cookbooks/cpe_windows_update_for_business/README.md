cpe_windows_update_for_business Cookbook
========================================

Requirements
------------
* Windows 10
* Certain functionality requires release version `10.0.17134.0` or higher.

Attributes
----------
* node['cpe_windows_update_for_business']['enabled']
* node['cpe_windows_update_for_business']['branch_readiness_level']
* node['cpe_windows_update_for_business']['defer_quality_updates_period_in_days']
* node['cpe_windows_update_for_business']['defer_feature_updates_period_in_days']
* node['cpe_windows_update_for_business']['pause_quality_updates_start_time']
* node['cpe_windows_update_for_business']['pause_feature_updates_start_time']
* node['cpe_windows_update_for_business']['exclude_wu_drivers_in_quality_update']
* node['cpe_windows_update_for_business']['target_release_version_info']
* node['cpe_windows_update_for_business']['defer_quality_updates']
* node['cpe_windows_update_for_business']['defer_feature_updates']
* node['cpe_windows_update_for_business']['product_version']

Usage
-----
This cookbook manages the configuation of Windows Update for Business,
allowing for more granular control over update offerings and experiences
via Windows Update service.

By default, this cookbook's attributes are set to `nil` but can be
overridden by assigning values to each of the resource's properties in the API:

```
  node.default['cpe_windows_update_for_business']['enabled'] = true
  node.default['cpe_windows_update_for_business']['branch_readiness_level'] = 2
  ...
```

### `node['cpe_windows_update_for_business']['enabled']`
Manages Windows Update for Business settings when set to `true`. Otherwise, the
cookbook will not do anything.

### `node['cpe_windows_update_for_business']['branch_readiness_level']`
Controls the service channel of feature updates for a machine to receive.
Acceptable values and their corresponding service channels can be found [in the
documentation](https://docs.microsoft.com/en-us/windows/deployment/update/waas-configure-wufb#summary-mdm-and-group-policy-settings-for-windows-10-version-1703-and-later)

There are helper libraries available to set known branches in the
`CPE::WindowsUpdateForBusiness::BranchReadinessLevel` module.

### `node['cpe_windows_update_for_business']['defer_quality_updates_period_in_days']`
Defers quality updates for `n` days where `n` is a value between `0` and `35`.

### `node['cpe_windows_update_for_business']['defer_feature_updates_period_in_days']`
Defers feature updates for `n` days where `n` is a value between `0` and `365`.

### `node['cpe_windows_update_for_business']['pause_quality_updates_start_time']`
Pauses quality updates starting at a specific date, specified in `yyyy-mm-dd`
format.

### `node['cpe_windows_update_for_business']['pause_feature_updates_start_time']`
Pauses quality updates starting at a specific date, specified in `yyyy-mm-dd`
format.

### `node['cpe_windows_update_for_business']['exclude_wu_drivers_in_quality_update']`
Exclude driver updates from update searches when set to `true`.

### `node['cpe_windows_update_for_business']['target_release_version_info']`
Beginning in Windows 10 1803 you may set a string containing a release version
that the device will try upgrade to. See the `Version` column in [the
documentation](https://aka.ms/ReleaseInformationPage) for how this value is
obtained.

### `node['cpe_windows_update_for_business']['defer_quality_updates']`
When set to `true` quality updates are deferred until the duration set in
`defer_quality_updates_period_in_days` has passed.

### `node['cpe_windows_update_for_business']['defer_feature_updates']`
When set to `true` feature updates are deferred until the duration set in
`defer_feature_updates_period_in_days` has passed.

### `node['cpe_windows_update_for_business']['product_version']`
Which major release of Windows to configure the device to pull updates for.

### Example

```ruby
node.default['cpe_windows_update_for_business'].merge!({
  'branch_readiness_level' => 4,
  'defer_quality_updates_period_in_days' => 20,
  'pause_quality_updates_start_time' => '2020-04-01',
  'defer_feature_updates_period_in_days' => 250,
  'pause_feature_updates_start_time' => 1,
  'exclude_wu_drivers_in_quality_update' => true,
  'product_version' => 'Windows 10',
  'target_release_version_info' => '20H2',
})
```

Note the use of `merge!` here instead of a direct assignment. This will ensure
that the defaults are preserved. If you override the API with a direct
assignment you **must** assign every value the API supports.
