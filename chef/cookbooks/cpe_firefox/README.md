cpe_firefox Cookbook
============================
Configures custom settings for Firefox via AutoConfig.

Requirements
------------
* Windows
* macOS
* Linux

Attributes
----------

* node['cpe_firefox']['cfg_file_name']
* node['cpe_firefox']['settings']
* node['cpe_firefox']['certs']
* node['cpe_firefox']['ff_base_paths']

Usage
-----
These are all applied using Mozilla's AutoConfig customization. Mozilla's official documentation refers to AutoConfig as the way to configure Firefox 59 and earlier and positions Policy Manager as the way to configure Firefox 60 and above. Despite this, AutoConfig remains perfectly supported in Firefox 60 and Policy Manager does not yet support most of what's possible using AutoConfig, nor is it clear if Policy Manager is even intended to fully replace AutoConfig. The documentation is also sparse for some interfaces; a lot of the certificate handling code was derived from a few different sites and the IDL files Mozilla publishes for their interfaces.

Some of the documentation I referenced along the way:

- https://developer.mozilla.org/en-US/Firefox/Enterprise_deployment_before_60#Configuration
  - This AutoConfig documentation only documents `pref()`, `lockPref()`, `defaultPref()`, and `unlockPref()`.
- https://mike.kaply.com/2012/03/16/customizing-firefox-autoconfig-files/
- https://mike.kaply.com/2012/03/20/customizing-firefox-autoconfig-files-continued/
- https://mike.kaply.com/2012/03/22/customizing-firefox-advanced-autoconfig-files/
  - These are written by the person who wrote CCK2, which Mozilla recommends be used when anything beyond setting preferences is needed or even for complex preferences.
- http://web.mit.edu/~firefox/www/maintainers/autoconfig.html
  - This page introduced the XPCOM interface and shows how to debug AutoConfig errors. If there is an error in the AutoConfig file Firefox will simply refuse to start and display an unhelpful generic message. The debugging method documented on this page makes fixing a bad AutoConfig less opaque.
- https://dxr.mozilla.org/mozilla-central/source/security/manager/ssl/nsIX509CertDB.idl
- https://dxr.mozilla.org/mozilla-central/source/xpcom/io/nsIFile.idl
- https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XPCOM/Reference/Interface/nsIFileInputStream
- https://dxr.mozilla.org/mozilla-central/source/netwerk/base/nsIFileStreams.idl
- https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XPCOM/Reference/Interface/nsIInputStream
- https://dxr.mozilla.org/mozilla-central/source/xpcom/io/nsIInputStream.idl
- https://dxr.mozilla.org/mozilla-central/source/xpcom/io/nsIBinaryInputStream.idl
  - These are documents related to the XPCOM interfaces

### Settings
`node['cpe_firefox']['cfg_file_name']` sets the name of the config file that gets written out in the Firefox directory.

`node['cpe_firefox']['settings']` is the hash that contains a hash of all the settings.

To find more parameters to set, use `about:config` in Firefox. See https://support.mozilla.org/en-US/kb/about-config-editor-firefox for details.

Each key in the hash is a preference key from `about:config` to manage. The value is a hash containing a `value` key and optional `locked`, `default`, and `clear` keys.

- `value`: the actual value for the setting.
- `locked` (optional): whether or not the setting can be changed by the user in about:config (default `false`). `lockPref()` is used if this is present and `true`, otherwise `unlockPref()` is called to ensure the preference is unlocked.
- `default` (optional): If this is present and `true`, `defaultPref()` will be used to set a default value instead of `pref()` to set a preference value.
- `clear` (optional): If this is present and `true`, `clearPref()` will be called to clear the value of the preference.

For example, to turn off the favicon setting and lock it from being changed:

```
node.default['cpe_firefox']['browser.chrome.favicons'] = {
  'value' => false,
  'locked' => true,
}
```

Please note, some `about:config` preferences are complex preferences and must be set accordingly. For example, the browser homepage; this line sets the browser homepage default value:

```
node.default['cpe_firefox']['browser.startup.homepage'] = {
  'value' => 'data:text/plain,browser.startup.homepage=http://home.example.com',
  'default' => true,
}
```

### Certificates
You can also add CA certificates to Firefox's certificate store or mark certificates as untrusted.

To import a CA certificate, the certificate file must be added to `files/default/firefox/resources/certs/`. The file names must be added to the `node['cpe_firefox']['certs']` attribute, which is an array of hashes. Do not include the path:

```
node.default['cpe_firefox']['certs'] += [
  {'cert' => 'MyCompanyCA.crt', 'trust' => 'C,,'},
  {'cert' => 'MyIntermediateCA.crt', 'trust' => 'C,,'},
  {'cert' => 'MyTrustedCert.crt', 'trust' => 'C,,'}
]
```

The `trust` key is the level of trust the cert should have. A CA certificate should be set to `C,,`. To distrust a certificate set `trust` to `,,`. See https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/Reference/NSS_tools_:_certutil and search for `trustargs` for details on how to set the `trust` string for trust other than as a server CA certificate.

### Base Paths
`node.default['cpe_firefox']['ff_base_paths']` contains a list of all Firefox installation top-level directories.
