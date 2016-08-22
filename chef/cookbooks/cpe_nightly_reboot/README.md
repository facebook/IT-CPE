cpe_nightly_reboot Cookbook
==================
This cookbook can produce two launch daemons: 
  * reboot at a specified time
  * logout & perform a Munki bootstrap at a specified time

The reboot launch daemon does a hard reboot (`/sbin/reboot`), which may potentially cause unsaved work to be lost. It may also be interrupted by a modal dialog asking for confirmation (such as iTerm or Terminal).

The logout & bootstrap forcefully kills all GUI login sessions, which may also cause potentially unsaved work to be lost.  It may also be interrupted by a modal dialog asking for confirmation (such as iTerm or Terminal).

Requirements
------------
* Mac OS X
* cpe_launchd
* Munki must be installed on the client machine

Attributes
----------
* node['cpe_nightly_reboot']['script']
* node['cpe_nightly_reboot']['restart']
* node['cpe_nightly_reboot']['logout']

Usage
-----
* `node['cpe_nightly_reboot']['script']`
This is the path to the script that is executed by `logout`. By default, this is located in /opt/chef/scripts/logout_bootstrap.py. This script must be in place for `logout` to work.

* `node['cpe_nightly_reboot']['restart']`  
The calendar time for a scheduled reboot.
See `man launchd.plist` for details on how the calendar interval in launchd works.

* `node['cpe_nightly_reboot']['logout']`  
The calendar time for a logout + Munki bootstrap.

**Values**: The hash should contain any of the following keys: *nil values are ignored, which launchd treats as wildcards*

* 'Month': 1 - 12
* 'Day': 1 - 31
* 'Weekday': 0 - 7 (0 and 7 are Sunday)
* 'Hour': 0 - 23
* 'Minute': 0 - 59

To set a nightly reboot time in your recipe, simply set a non-nil value to at least one of the keys in the calendar hash.

This example will install a launch daemon that will reboot the machine at midnight:

    # Nightly reboot
    node.default['cpe_nightly_reboot']['restart'] = {
      'Hour' => 0,
      'Minute' => 0
    }

Same thing for a logout + bootstrap.  This will set a logout time of 11:00 PM local time:

    # Nightly logout + bootstrap
    node.default['cpe_nightly_reboot']['logout'] = {
      'Hour' => 23,
      'Minute' => 0
    }
