cpe_init cookbook
=================

Description
-----------
This is a sample - you almost certainly want to fork this and adjust it to taste.
The rest of the IT-CPE suite of cookbooks are designed to not be locally modified.

Requirements
------------

Usage
-----
Before you add a `include_recipe 'recipe'` statement be sure to add a
`depends 'cookbook'` to the metadata.rb

This cookbook includes all of the opensource IT-CPE cookbooks. You may not be
ready to use them all, or you may want to include additional stuff, so adjust
to taste.

We've gone ahead and included some extra `HERE:` comments on where we've put
other cookbooks that are internal to give you a better idea of our full runlist.
We hope to be able to release more of these as time allows and where
appropriate.

The general idea is that cookbooks are ordered least specific to most specific.
This allows a small core team to make APIs and defaults and then let individual
service owners' cookbooks at the end overwrite whatever they ened to. This also
ensures that all things the service owner chooses not to bother with are setup
to sane settings by the core group at your site.

The idea is that your runlists will include this first, then everything else.
This cookbook should be every "core cookbook" that provides APIs for everyone
else.

It's useful to think of things in a 3-pass system:

* **Setup APIs** - This is what we do in attributes files. Create the structure
in the node object for people to append to or modify.
* **Use APIs** -  In recipes any cookbook can use those APIs by simply writing
to the node object. The cookbooks in question can set things, but it can all be
overwritten by "owners" later. This is where the ordering of our model is
different from other models - we start with the most generic stuff -
the cookbooks the core OS team writes that should be applicable in general to
all machines unless someone has a more specific desire. Owners then can include
other cookbooks that are more specific - maybe for a specific cluster, location,
type of service. Finally the last cookbooks should be the most specific ones for
that service or machine which gets the final say. Anytime someone removes a node
assignment the next-most-specific setting will take precedent.

* **Consume APIs** Everyone who uses any API is generally the cookbook that
provides that API, so APIs must be consumed only at runtime: `templates`,
`ruby_blocks`, `providers`, etc.

We have provided an early recipe called `company_init.rb` in which you can set
the defaults for your organization for all settings CPE cookbooks provide.
For example, setting your organization and which `managed_installs` you want
in your local munki manifests would be reasonable.

Then, you can let others override them in their later cookbooks. Assuming
cpe_init is the first thing in your runlist, this is basically the first thing,
so any other cookbooks in your runlist will have time to overwrite them.

### cpe_init::default
This is where we conditionally set which cookbook/recipe should be added to the
`run_list`. We have some built in logic that will allow you to scope to the
following things:

#### Based on platform
* node.macos?
* node.linux?

#### Based on OS version
* node.os_less_than?('10.11')
* node.os_at_least?('10.10')

Apart from API cookbooks, this includes 3 recipes / cookbooks:

* `cpe_init::company_init
   see above
* `cpe_user_customizations`
   This is where all user-specific customizations should live. Generally
   these recipes are used to change settings via API cookbooks.
* `cpe_node_customizations`
   This is where all node-specific customizations should live. Generally
   these recipes are used to change settings via API cookbooks.

Contributing
------------

**DO NOT FORGET:** If you are calling an external cookbook Before you add an
`include_recipe 'recipe'` statement be sure to add a `depends 'cookbook'` to the
metadata.rb


