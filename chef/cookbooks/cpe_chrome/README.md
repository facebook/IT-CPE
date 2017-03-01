cpe_chrome Cookbook
============================
Configures any custom settings for Google Chrome, or Chrome Canary.

Requirements
------------
* Mac OS X
* Mac OS X version depends on cpe_profiles

Attributes
----------

* node['cpe_chrome']
* node['cpe_chrome']['profile']['ExtensionInstallForcelist']
* node['cpe_chrome']['profile']['ExtensionInstallBlacklist']
* node['cpe_chrome']['profile']['ExtensionInstallSources']
* node['cpe_chrome']['profile']['EnabledPlugins']
* node['cpe_chrome']['profile']['DisabledPlugins']
* node['cpe_chrome']['profile']['DefaultPluginsSetting']
* node['cpe_chrome']['profile']['PluginsAllowedForUrls']
* node['cpe_chrome']['mp']['UseMasterPreferences']
* node['cpe_chrome']['mp']['FileContents']

Usage
-----
#### cpe_chrome::default
includes 3 recipes:

* `cpe_browsers::(mac_os_x|windows)_chrome`
    * Manages all aspects of the Google Chrome browser for both Mac and Windows.

* `cpe_browsers::mac_os_x_chrome_canary`
    * Manages all aspects of the Google Chrome Canary browser just for Mac OS X.
    * This recipe behaves identically to the Google Chrome recipe, and uses the same settings, but only applies if Chrome Canary is installed.

`node['cpe_chrome']['profile']` is the hash that contains a hash of all the settings.  

The profile's organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe.

For Chrome and Chrome Canary the list of managed polices can be found here:
https://www.chromium.org/administrators/policy-list-3

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

#### Master Preferences
A Master Preferences file can be generated for use with first time Google Chrome is launched. This is useful if you would like to set "first-run" values, but not manage them.

In order to use this, you must pass a `true` value to node['cpe_chrome']['mp']['UseMasterPreferences'].

    node.default['cpe_chrome']['mp']['UseMasterPreferences'] = true

As the Google Master Preferences file is inherently a JSON file, you can pass all attributes in a ruby hash:

    # Set Master Preferences
    node.default['cpe_chrome']['mp']['FileContents'] = {
      'homepage' => 'https://example.tld',
      'browser' => {
        'show_home_button' => true
      },
      'bookmark_bar' => {
        'show_on_all_tabs' => true
      },
      'distribution' => {
        'skip_first_run_ui' => true,
        'make_chrome_default' => true,
        'make_chrome_default_for_user' => true,
        'suppress_first_run_default_browser_prompt' => true
      }
    }

#### Plugins
Plugins can be enabled or disabled by policy.

* `node['cpe_chrome']['profile']['EnabledPlugins']`
* `node['cpe_chrome']['profile']['DisabledPlugins']`

The enabled/disabled lists are arrays of values strings that can contain "*" or "?" wildcards.  See https://www.chromium.org/administrators/policy-list-3#EnabledPlugins for details.
