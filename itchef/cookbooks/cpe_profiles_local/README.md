cpe_profiles_local Cookbook
=====================
This is a cookbook that will manage all of the configuration profiles used with
Chef.

Requirements
------------
* macOS (10.9.0 and higher)
* fb_helpers (from https://github.com/facebook/chef-cookbooks/)

Attributes
----------
* node['cpe_profiles_local']
* node['cpe_profiles_local']['prefix']

Usage
-----
Include this recipe and add any configuration profiles matching the format in the
example below.

**Note:** If you use this outside of Facebook, ensure that you override the
default value of `node['cpe_profiles_local']['prefix']`. If you do not do this, it
will assume a `PayloadIdentifier` prefix of `com.facebook.chef`.

**THIS MUST GO IN A RECIPE. DO NOT PUT THIS IN ATTRIBUTES, OR IT MAY CAUSE PAIN
AND SUFFERING FOR YOUR FLEET!**

To add a new config profile, in your recipe, add a key matching the
profile `PayloadIdentifier` with a value that contains the hash of the profile
to `node.default['cpe_profiles_local']`

For instance, add a hash to manage the loginwindow and use the default prefix:

```
lw_prefs = node['cpe_loginwindow'].reject { |\_k, v| v.nil? }
if lw_prefs.empty?
  Chef::Log.debug("#{cookbook_name}: No prefs found.")
  return
end

prefix = node['cpe_profiles_local']['prefix']
organization = node['organization'] ? node['organization'] : 'Facebook'
lw_profile = {
  'PayloadIdentifier' => "#{prefix}.loginwindow",
  'PayloadRemovalDisallowed' => true,
  'PayloadScope' => 'System',
  'PayloadType' => 'Configuration',
  'PayloadUUID' => 'e322a110-e760-40f7-a2ee-de8ee41f3227',
  'PayloadOrganization' => organization,
  'PayloadVersion' => 1,
  'PayloadDisplayName' => 'LoginWindow',
  'PayloadContent' => [],
}
unless lw_prefs.empty?
  lw_profile['PayloadContent'].push(
    'PayloadType' => 'com.apple.loginwindow',
    'PayloadVersion' => 1,
    'PayloadIdentifier' => "#{prefix}.loginwindow",
    'PayloadUUID' => '658d9a18-370e-4346-be63-3cb8a92cf71d',
    'PayloadEnabled' => true,
    'PayloadDisplayName' => 'LoginWindow',
  )
  lw_prefs.keys.each do |key|
    next if lw_prefs[key].nil?
    lw_profile['PayloadContent'][0][key] = lw_prefs[key]
  end
end
```

**If you already have profiles installed using an existing prefix, be sure to
convert all of them over to the new prefix. There will be pain and suffering if this
is not done.**

Or, if you want to customize the prefix and then add a profile, you would do:

```
# Override the default prefix value of 'com.facebook.chef'
node.default['cpe_profiles_local']['prefix'] = 'com.company.chef'
# Use the specified prefix to name the configuration profile
lw_prefs = node['cpe_loginwindow'].reject { |\_k, v| v.nil? }
if lw_prefs.empty?
  Chef::Log.debug("#{cookbook_name}: No prefs found.")
  return
end

prefix = node['cpe_profiles_local']['prefix']
organization = node['organization'] ? node['organization'] : 'Facebook'
lw_profile = {
  'PayloadIdentifier' => "#{prefix}.loginwindow",
  'PayloadRemovalDisallowed' => true,
  'PayloadScope' => 'System',
  'PayloadType' => 'Configuration',
  'PayloadUUID' => 'e322a110-e760-40f7-a2ee-de8ee41f3227',
  'PayloadOrganization' => organization,
  'PayloadVersion' => 1,
  'PayloadDisplayName' => 'LoginWindow',
  'PayloadContent' => [],
}
unless lw_prefs.empty?
  lw_profile['PayloadContent'].push(
    'PayloadType' => 'com.apple.loginwindow',
    'PayloadVersion' => 1,
    'PayloadIdentifier' => "#{prefix}.loginwindow",
    'PayloadUUID' => '658d9a18-370e-4346-be63-3cb8a92cf71d',
    'PayloadEnabled' => true,
    'PayloadDisplayName' => 'LoginWindow',
  )
  lw_prefs.keys.each do |key|
    next if lw_prefs[key].nil?
    lw_profile['PayloadContent'][0][key] = lw_prefs[key]
  end
end
```
