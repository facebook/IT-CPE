Description
=================
This is the very basic cookbook that starts it all. Be very careful, have
proper code reviews, because you can break our entire fleet. You are warned.

Requirements
=================
Before you add a `include_recipe 'recipe'` statement be sure to add a
`depends 'cookbook'` to the metadata.rb

Usage
=================
#### cpe_init::default
includes 3 recipes:

* `cpe_init::#{node['platform_family']}_init`
    * Each platform will have a _init recipe. This is where we conditionally
    create the run_list by platform.
* `cpe_user_customizations`
    * This is where all user-specific customizations should live. Generally 
    these recipes are used to change settings via API cookbooks.
* `cpe_node_customizations`
    * This is where all node-specific customizations should live. Generally 
    these recipes are used to change settings via API cookbooks.

#### cpe_init::mac_osx_init
This is where we conditionally set which cookbook/recipe should be added to the
mac run_list. We have some built in logic that will allow you to scope to the
following things:

###### Based on platform:
* node.macosx?
* node.linux?

###### Based on OS version:
* node.os_less_than?('10.11')
* node.os_at_least?('10.10')


Contributing
=================

**DO NOT FORGET: ** If you are calling an external cookbook Before you add an
`include_recipe 'recipe'` statement be sure to add a `depends 'cookbook'` to the
metadata.rb


