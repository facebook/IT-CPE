cpe_appaccess Cookbook
========================
Install a profile to manage access to executing applications in specific paths.

Attributes
----------
* node['cpe_appaccess']['pathBlackList']
* node['cpe_appaccess']['pathWhiteList']

Usage
-----
The profile will manage the `com.apple.applicationaccess` preference domain.

The organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe. The profile will also use
whichever prefix is set in node['cpe_profiles']['prefix'], which defaults
to `com.facebook.chef`

The profile delivers an array payload for the above keys.

For example;

	# Don't allow downloaded applications.
	node.default['cpe_appaccess']['pathBlackList'] = [
		'/Users',
	]

	node.default['cpe_appaccess']['pathWhiteList'] = [
		'/',
	]
