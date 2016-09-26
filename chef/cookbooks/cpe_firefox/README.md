cpe_firefox Cookbook
============================
Configures custom settings for Firefox via CCK2.

Requirements
------------
Debian-based platform, Mac OS X, or Windows.

Attributes
----------

* node['cpe_firefox']['settings']
* node['cpe_firefox']['settings']['network.negotiate-auth.allow-non-fqdn']
* node['cpe_firefox']['settings']['network.negotiate-auth.trusted-uris']
* node['cpe_firefox']['settings']['network.proxy.type']
* node['cpe_firefox']['settings']['plugin.state.flash']
* node['cpe_firefox']['settings']['plugins.click_to_play']
* node['cpe_firefox']['certs']

Usage
-----
These are all applied using Mike Kaply's CCK2 customization.  See https://mike.kaply.com/cck2/ for details.

==Settings==
To find more parameters to set, use `about:config` in Firefox.
See https://support.mozilla.org/en-US/kb/about-config-editor-firefox for details.

`node['cpe_firefox']['settings']` is the hash that contains a hash of all the settings.

Each key in the hash is a preference key from about:config to manage. The value is a hash containing a "value" key and optional "locked" key.  

* "value" -> the actual value for the setting
* "locked" (optional) -> whether or not the setting can be changed by the user in about:config

For example, to turn off the favicon setting and lock it from being changed:

    node.default['cpe_firefox']['browser.chrome.favicons'] = {
      'value' => false,
      'locked' => true
    }

==Certificates==
You can also add certificates to Firefox's certificate store. 

The files must be added to files/default/firefox/cck2/resources/certs/. The file names should be added to the `node['cpe_firefox']['certs']` node attribute, which should just be an array of file names. Do not include the path:

    node.default['cpe_firefox']['certs'] += [
      'MyCompanyCA.crt',
      'MyIntermediateCA.crt',
      'MyTrustedCert.crt'
    ]
These settings are applied using Mike Kaply's CCK2 customization.  See https://mike.kaply.com/cck2/ for details.

Special Note: If you intend to modify the cck template, you MUST increment the version number in the cck2.erb file or else the client will never get the updated file. E.g. if you update the template but keep the same version number, the new cck file will NOT get applied.
