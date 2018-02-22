cpe_chrome Cookbook
============================
Configures any custom settings for Google Chrome, or Chrome Canary.

Requirements
------------
Linux, Mac OS X, or Windows

Attributes
----------

* node['cpe_chrome']['profile']
* node['cpe_chrome']['mp']

Usage
-----
#### cpe_chrome::default
includes two platform-specific recipes:

* `cpe_chrome::(mac_os_x|windows)_chrome`
    * Manages all aspects of the Google Chrome browser for both Mac and Windows.

`node['cpe_chrome']` is the hash that contains a hash of all the settings.

The profile's organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe.

# Managed Policies

For Chrome and Chrome Canary the list of managed polices can be found here:
https://www.chromium.org/administrators/policy-list-3

All policy-managed settings are stored in the node['cpe_chrome']['profile'] hash.

To add a managed setting to your profile, simply add the key from the URL list above to this hash:

    node.default['cpe_chrome']['profile']['BookmarkBarEnabled'] = true

#### Extensions installed by policy
`node['cpe_chrome']['profile']['ExtensionInstallForcelist']`

* Extensions that are installed by policy (and cannot be disabled by the user)
* Must be the extension ID followed by the Update URL.
* The extension ID can be found in the URL from the Web Store, or at [chrome://extensions]()
* The Update URL for the Chrome Web Store is always "https://clients2.google.com/service/update2/crx"
This example is the Messenger Screen Sharing extension from the Web Store:

    `degmgkchmbgaognjjlhggmhbcpicdifm;https://clients2.google.com/service/update2/crx`


To add your own, simply add to this array:

    # Install the LastPass extension
    chrome_ext_update_url = 'https://clients2.google.com/service/update2/crx'
    node.default['cpe_chrome']['profile']['ExtensionInstallForcelist'] <<
      "hdokiejnpimakedhajhdlcegeplioahd;#{chrome_ext_update_url}"

Likewise, extensions can be blacklisted (and thus forcibly removed from your browser):

    # Forecefully remove the BetterHistory malware extension
    node.default['cpe_chrome']['profile']['ExtensionInstallBlacklist'] <<
      "obciceimmggglbmelaidpjlmodcebijb"

`node['cpe_chrome']['profile']['ExtensionInstallSources']` is a list of URL sources where extensions may be installed from.  See https://www.chromium.org/administrators/policy-list-3#ExtensionInstallSources for details.

#### Plugins
Plugins can be enabled or disabled by policy.

* `node['cpe_chrome']['profile']['EnabledPlugins']`
* `node['cpe_chrome']['profile']['DisabledPlugins']`

The enabled/disabled lists are arrays of values strings that can contain "*" or "?" wildcards.  See https://www.chromium.org/administrators/policy-list-3#EnabledPlugins for details.

# Master Preferences

In addition to enforcing managed policies, this cookbook can also manage the 'Master Preferences' file.
See https://www.chromium.org/administrators/configuring-other-preferences for details.

The Master Preferences file configuration is handled by the `node['cpe_chrome']['mp']['FileContents']` hash.
This hash should contain keys that are described in the link above.  An example:

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

The Master Preferences file will only be written to disk if the node attribute `node['cpe_chrome']['mp']['UseMasterPreferencesFile']` is `true`:

  node.default['cpe_chrome']['mp']['UseMasterPreferencesFile'] = true

