cpe_powermanagement Cookbook
=========================
Manages the powermanagement profile settings. This should only apply to Dashboards, Lobbies, Imaging servers, and Wayfinders.

If any of the values of the attributes are non-nil, a profile is created and applied to the machine. No profile is applied if all of the values are nil.


Requirements
------------
This can be run on any OS X machine, but this is really intended to only apply to dashboards, lobbies, imaging servers, and wayfinders, which need special power configurations.


Attributes
----------
* node['cpe_powermanagement']['ACPower']['Automatic Restart On Power Loss']
* node['cpe_powermanagement']['ACPower']['Disk Sleep Timer']
* node['cpe_powermanagement']['ACPower']['Display Sleep Timer']
* node['cpe_powermanagement']['ACPower']['Sleep On Power Button']
* node['cpe_powermanagement']['ACPower']['System Sleep Timer']
* node['cpe_powermanagement']['ACPower']['Wake On LAN']
* node['cpe_powermanagement']['ACPower']['RestartAfterKernelPanic']

* node['cpe_powermanagement']['Battery']['Automatic Restart On Power Loss']
* node['cpe_powermanagement']['Battery']['Disk Sleep Timer']
* node['cpe_powermanagement']['Battery']['Display Sleep Timer']
* node['cpe_powermanagement']['Battery']['Sleep On Power Button']
* node['cpe_powermanagement']['Battery']['System Sleep Timer']
* node['cpe_powermanagement']['Battery']['Wake On LAN']
* node['cpe_powermanagement']['Battery']['RestartAfterKernelPanic']

Usage
-----
There are two sets of attributes that are identical - 'ACPower' for when on AC power (plugged in), and 'Battery' for when on battery.

'Battery' settings will have no effect on desktops (and will not be applied by this recipe).

Descriptions for these settings can be found by looking at `man pmset` and `man systemsetup`.  The key names are chosen from /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist.

You can specify arbitrary keys to go in these, but please make sure you test thoroughly and are very sure about the keynames and acceptable values. If the profile does not pass validation by the OS, it will not install (and your settings will not apply).

The profile's organization key defaults to `Facebook` unless `node['organization']` is
configured in your company's custom init recipe.

The supported and provided keys all live in `node['cpe_powermanagement']`:

* `node['cpe_powermanagement']['ACPower']['Automatic Restart On Power Loss']`  
Automatically restart if a power failure occurs  
**Values**: true/false  
* `node['cpe_powermanagement']['ACPower']['Disk Sleep Timer']`  
Put hard disks to sleep after this idle time  
**Values**: Integer, number of minutes  
* `node['cpe_powermanagement']['ACPower']['Display Sleep Timer']`  
Put monitor/display to sleep after this idle time  
**Values**: Integer, number of minutes  
* `node['cpe_powermanagement']['ACPower']['Sleep On Power Button']`  
Pressing the power button immediately invokes sleep  
**Values**: true/false  
* `node['cpe_powermanagement']['ACPower']['System Sleep Timer']`  
Put system to sleep after this idle time  
**Values**: Integer, number of minutes  
* `node['cpe_powermanagement']['ACPower']['Wake On LAN']`  
Wake for a magic network packet  
**Values**: true/false  
* `node['cpe_powermanagement']['ACPower']['RestartAfterKernelPanic']`  
Automatically restart after a kernel panic / freeze  
**Values**: true/false  

The same settings exist for Battery:  

* `node['cpe_powermanagement']['Battery']['Automatic Restart On Power Loss']`  
etc.  

To set values for these keys, override the setting in your recipe:

    node.default['cpe_powermanagement']['ACPower']['System Sleep Timer'] = 60

Example for how to set a series of these settings at once, in a recipe:

    # AC power settings
    {
      'Disk Sleep Timer' => 10,
      'System Sleep Timer' => 0,
      'Wake On LAN' => true
    }.each do |k, v|
      node.default['cpe_powermanagement']['ACPower'][k] = v
    end
    # Battery settings
    {
      'Disk Sleep Timer' => 20,
      'System Sleep Timer' => 30,
      'Wake On LAN' => false
    }.each do |k, v|
      node.default['cpe_powermanagement']['Battery'][k] = v
    end
