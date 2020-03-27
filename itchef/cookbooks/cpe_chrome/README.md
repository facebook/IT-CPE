cpe_chrome
==========

Description
-----------
Configures any custom settings for Google Chrome, or Chrome Canary.

Requirements
------------
* Linux
* macOS
* Windows

Attributes
----------
* node['cpe_chrome']['profile']
* node['cpe_chrome']['mp']
* node['cpe_chrome']['canary_ignored_prefs']

Usage
-----
Manage all of the Chrome settings and the Master Preferences file.
`node['cpe_chrome']['profile']` is a hash of all the settings that will be
applied as managed policies. `node['cpe_chrome']['mp']` is a hash of all
settings that will be applied in Master Preferences.

### Managed Policies

For Chrome and Chrome Canary the list of managed polices can be found here:
https://cloud.google.com/docs/chrome-enterprise/policies

All policy-managed settings are stored in the node['cpe_chrome']['profile'] hash.

To add a managed setting to your profile, simply add the key from the URL list
above to this hash:

```
{
  'DefaultBrowserSettingEnabled' => false,
  'SitePerProcess' => true
}.each do |k, v|
  node.default['cpe_chrome']['profile'][k] = v
end
```

To exclude a managed setting from Chrome Canary, add the key to the array:

```
{
  'RelaunchNotification',
  'RelaunchNotificationPeriod',
}.each do |setting|
  node.default['cpe_chrome']['canary_ignored_prefs'] << setting
end
```

#### Extensions managed by policy

`node['cpe_chrome']['profile']['ExtensionInstallForcelist']`

* Extension ids added here are enforced by policy and cannot be disabled by
  the user
* Must be the extension ID followed by the Update URL.
* The extension ID can be found in the URL from the Web Store, or at
  [chrome://extensions]()
* The Update URL for the Chrome Web Store is always
  "https://clients2.google.com/service/update2/crx"

This example is the LastPass extension from the Chrome Web Store:

```
# Install the LastPass extension
chrome_ext_update_url = 'https://clients2.google.com/service/update2/crx'
{
  'ExtensionInstallForcelist' => [
    "hdokiejnpimakedhajhdlcegeplioahd;#{chrome_ext_update_url}",
  ],
}.each do |k, v|
  node.default['cpe_chrome']['profile'][k] = v
end
```

Likewise, extensions can be blacklisted (and thus forcibly removed from
the browser by policy):

```
# Forcefully remove the BetterHistory malware extension
chrome_ext_update_url = 'https://clients2.google.com/service/update2/crx'
{
  'ExtensionInstallBlacklist' => [
    'obciceimmggglbmelaidpjlmodcebijb',
  ],
}.each do |k, v|
  node.default['cpe_chrome']['profile'][k] = v
end
```

`node['cpe_chrome']['profile']['ExtensionInstallSources']` is a list of URL
sources where extensions may be installed from.
See https://cloud.google.com/docs/chrome-enterprise/policies/?policy=ExtensionInstallSources
for details.

### Master Preferences

In addition to enforcing managed policies, this cookbook can also manage the
'Master Preferences' file.
See https://www.chromium.org/administrators/configuring-other-preferences for
details.

The Master Preferences file configuration is handled by the
`node['cpe_chrome']['mp']['FileContents']` attribute.
This hash should contain keys that are described in the link above.  An example:

```
node.default['cpe_chrome']['mp']['FileContents'] = {
  'bookmark_bar' => {
    'show_all_tabs' => true,
  },
  'distribution' => {
    'import_bookmarks' => false,
    'skip_first_run_ui' => false,
    'show_welcome_page' => false,
    'suppress_first_run_bubble' => true,
    'do_not_register_for_update_launch' => false,
    'verbose_logging' => true,
  },
  'first_run_tabs' => [
    'https://www.facebook.com',
  ],
  'homepage' => 'http://www.facebook.com',
  'sync_promo' => {
    'show_on_first_run_allowed' => false,
  },
  'browser' => {
    'check_default_browser' => false,
  },
}
```

The Master Preferences file will only be written to disk if the node attribute
`node['cpe_chrome']['mp']['UseMasterPreferencesFile']` is `true`:

```
  node.default['cpe_chrome']['mp']['UseMasterPreferencesFile'] = true
```

### Linux

On Linux, to avoid installing chrome and the repos, your node must have
the attributes `manage_repo` and `install_package` set to `false`:

```
  node.default['cpe_chrome']['manage_repo'] = false
  node.default['cpe_chrome']['install_package'] = false
```

These attributes are set to true by default. It can be disabled by
adding the above commands to your cpe_user_customizations::${USER}.

*macOS Only*
The profile's organization key defaults to `Facebook` unless
`node['organization']` is configured in your company's custom init recipe.

### Windows compatibility

On Windows, Chrome policy is stored in the registry, in
`HKEY_LOCAL_MACHINE\\Software\\Policies\\Google\\Chrome`. These registry keys
here are mapped from the `node['cpe_chrome']['profile']` attribute in the
chrome_windows.rb library, which provide a class that converts them.

As Google adds new keys and deprecates old ones, they may need to be manually
added to the chrome_windows.rb library in order to provide support and
compatibility.

This cookbook will automatically cleanup subkeys that are stored in the policy
registry key but are not found in the node attribute.

#### New Windows Provider

We are dogfooding generating settings directly from a reference file provided
in the Chrome ADMX template. This does not cover *every* setting, so we also
will generate policies from a separate reference file that is manually
maintained. All reference files are `.reg` files.

To manually add a registry setting you can add it to
`win_chrome_manual_policy.reg`.

To generate settings run the script `windows_policy_gen.rb`. This assumes you
have the chefdk installed locally.

All generated settings are placed
into `libraries/gen_windows_chrome_known_settings.rb`.

To use the provider in your environment you need to enable it:

  node.default['cpe_chrome']['_use_new_windows_provider'] = true

The new provider is a drop-in replacement, you don't need to take any further
action aside from enabling it to use it.
