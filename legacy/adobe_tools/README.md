# Adobe Tools

The three pieces involved here are the API interaction module, the public interaction module, and example scripts. You will need to place these on the client machines in some space where they will be within the Python path. 

For more information about this, please see the blog post:  
https://osxdominion.wordpress.com/2016/10/19/self-service-adobe-cc-in-munki/


## The adobe_api Module

This is the primary module for interacting with the [Adobe User Management API](https://www.adobe.io/products/usermanagement/docs/gettingstarted). It has a class named `AdobeAPIObject`, which allows interaction with the API. Information queried from the API, such as the product list, user list, and individual user data is stored in this object.

This object also stores a cache on disk (which lasts 6 hours before being automatically invalidated) for faster lookups after the initial queries, unless intentionally instantiated with `cache=False`.

You'll need to have the `usermanagement.config` and `private.key` files in place somewhere, as [documented on the API website](https://www.adobe.io/products/usermanagement/docs/samples#setup). The code as is written assumes they're located in `/Library/Adobe`, but you can move those files anywhere.

The arguments to the `AdobeAPIObject`:
* `username` - defaults to the current logged in GUI user
* `private_key_filename` - path to the private key
* `userconfig` - path to the user management configuration (in JSON)
* `cache_path` - path to where the object cache is stored
* `cache` - whether we should read from and write to the cache when querying
* `key` - whether we should match users based on username or email address; defaults to email


## The adobe_tools Module

This module provides a number of public convenience functions for interacting with the [Adobe User Management API](https://www.adobe.io/products/usermanagement/docs/gettingstarted). 

When using this module, the public functions will handle all appropriate config and setup necessary, and will provide the data without requiring anything else.  For example, to query whether or not a given user exists:
```
email = 'test@example.com'
result = adobe_tools.user_exists(email)
print result
```

Querying if a user is a federated ID:
```
email = 'test@example.com'
result = adobe_tools.user_is_federated(email)
print result
```

## The Example Scripts

You must make sure that the `adobe_tools` module is in the Python path for these scripts.

Please note that these scripts, as written, require you to fill in some details about how the user's email and federated ID is generated. If you have an LDAP/AD to query, you'll want to do that. If the usernames also match their email (i.e. "username@domain.com" is their valid email), that's also an easy way to add accounts. Best not to rely on the assumptions that were made to generalize it.

The entitlements are the names of the product configurations listed in your Adobe enterprise dashboard. You can also get the list of products from the module:
```
product_list = adobe_tools.get_product_list()
```

### add_adobe.py
This script is a one-stop shop for adding a user and providing them entitlements.

Call this script with the product configuration you wish to add as an argument, and the following steps will happen:

* Does the user currently exist as a federated ID?
* If not, create a federated ID for this user.
* Does the user currently have the product entitlement?
* If not, add the product entitlement to this federated ID.

For example, to add the default After Effects product configuration:
```
$ add_adobe.py "Default After Effects CC - 0 GB Configuration"
```

The script will exit 0 if it successfully adds the entitlement (even if it had to create the user in the process); otherwise it will exit 1 for any other reason.


### munki_preinstall_adobe.py
This script is intended to be used as an `installcheck_script` for Adobe items in a Munki repo. It will check whether a given user exists and has the entitlement passed in as an argument. Note that since this is intended to be used solely as an optional install in Managed Software Center, this always assumes that the current user is the intended user.

Call this script with the product configuration you wish to verify:
```
$ munki_preinstall_adobe.py "Default After Effects CC - 0 GB Configuration"
```
The script will exit 1 if the user exists and does have the product entitlement; otherwise it will exit 0 for any other reason.


### munki_uninstall_adobe.py
This script will remove an entitlement from a user, if the user exists and has the entitlement.

```
$ munki_uninstall_adobe.py "Default After Effects CC - 0 GB Configuration"
```
The script will exit 1 if it fails to remove the entitlement; otherwise it will exit 0 for any other reason.
