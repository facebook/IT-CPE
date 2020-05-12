cpe_helpers Cookbook
====================
Node helper methods for Facebook IT-CPE open-source cookbooks.

Requirements
------------
This cookbook requires that Facebook's `fb_helpers` cookbook (found [here](https://github.com/facebook/chef-cookbooks/tree/master/cookbooks/fb_helpers)) exists within your Chef repository.

Attributes
----------

Usage
-----
### node methods
Simply depend on this cookbook from your metadata.rb to get these methods in
your node.

* `node.chef_greater_than?(v)`
    Takes a string representing a version, and returns true if the Chef version
    is strictly greater than that version

* `node.chef_is?(v)`
    Takes a string representing a version, and returns true if the Chef version
    is exactly that version

* `node.chef_less_than?(v)`
    Takes a string representing a version, and returns true if the Chef version
    is strictly less than that version

* `node.os_at_least?(v)`
    Takes a string representing a version, and returns true if the OS version
    is equal, or greater than, that version

* `node.os_at_most?(v)`
    Takes a string representing a version, and returns true if the OS version
    is equal, or less than, that version

* `node.os_greater_than?(v)`
    Takes a string representing a version, and returns true if the OS version
    is strictly greater than that version

* `node.os_less_than?(v)`
    Takes a string representing a version, and returns true if the OS version
    is strictly less than that version

### CPE::Helpers
The following methods are available:
