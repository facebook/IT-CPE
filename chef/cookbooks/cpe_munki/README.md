cpe_munki Cookbook
========================
cpe_munki is used to install and configure munki. It can install only, configure only, or both. It can also handle munkireports install and configuration if desired.

Attributes
----------
* node['cpe_munki']
* node['cpe_munki']['install'] 
* node['cpe_munki']['configure']
* node['cpe_munki']['preferences']
* node['cpe_munki']['local']['managed_installs'] 
* node['cpe_munki']['local']['managed_uninstalls']
* node['cpe_munki']['munki_version_to_install']
* node['cpe_munki']['munkireports']['install']
* node['cpe_munki']['munkireport']['baseurl']
* node['cpe_munki']['munkireport']['password'] 
* node['cpe_munki']['munkireport']['report_items']

Usage
-----
This cookbook handles the various aspects of a munki install. To use this cookbook,
set the attributes according to what you want to do and the cookbook will handle the rest.

Examples:

**Install munki and do nothing else**

    node.default['cpe_munki']['install']  = true

**Install and configure munki**

    node.default['cpe_munki']['install'] = true
    node.default['cpe_munki']['configure'] = true
    node.default['cpe_munki']['preferences']['SoftwareRepoURL'] =
      'https://munki.MYCOMPANY.com/repo'
    node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] =
      true

**Only configure munki**

    node.default['cpe_munki']['configure'] = true
    node.default['cpe_munki']['preferences']['SoftwareRepoURL'] =
      'https://munki.MYCOMPANY.com/repo'
    node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] =
      true
    node.default['cpe_munki']['preferences']['AppleSoftwareUpdatesOnly'] =
      true

Advanced Example:

**Note: You must have a munki server setup and all packages you add to this attr
must be available in the node's munki catalog**

**Add managed_installs using a local manifest**

    managed_installs = [
      'Firefox',
      'Chrome'
    ]
    managed_installs.each do |item|
      node.default['cpe_munki']['local']['managed_installs'] << item
    end

