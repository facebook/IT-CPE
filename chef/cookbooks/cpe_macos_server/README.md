cpe_macos_server Cookbook
==================
An API to configure macOS Server.app. It will perform the first-time setup of Server.app if necessary, and continually maintain any settings specified in the attributes.

Requirements
=================
* macOS
* Server.app must be installed

Attributes
=================
* node['cpe_macos_server']['setup']
* node['cpe_macos_server']['manage']
* node['cpe_macos_server']['services']
* node['cpe_macos_server']['services'][service_name]
* node['cpe_macos_server']['services'][service_name]['run']

Usage
=================

To set up Server.app for the first time, `node['cpe_macos_server']['setup']` must be `true`. If Server.app is present on the machine and not in a configured state (defined by the presence or lack of `/var/db/.ServerSetupDone`), this cookbook will perform the necessary setup tasks.

In order for the cookbook to configure any services or settings, `node['cpe_macos_server']['manage']` must also be set to `true`.

Settings to be applied are defined as keys in the `node['cpe_macos_server']['services']` attribute namespace. Each key inside the `node['cpe_macos_server']['services']` hash should be the name of a service, which can be found in:

    serveradmin list

Each service in `node['cpe_macos_server']['services']` should be a hash of key/value pairs corresponding to the settings for that particular service. The settings keys can be found in:

    serveradmin settings <service>

For example, to get a list of all settings for the AFP service:

    serveradmin settings afp

Every service that is defined in `node['cpe_macos_server']['services']` will be started.

Note that removing a service from the attribute will NOT disable the service. This cookbook does not disable any services.
