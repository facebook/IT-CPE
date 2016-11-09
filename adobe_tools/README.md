# Adobe Tools

The two pieces involved here are a module, and a script. You will need to place these on the client machines in some space where they will be within the Python path. 

For more information about this, please see the blog post:
[https://osxdominion.wordpress.com/2016/10/19/self-service-adobe-cc-in-munki/]()

## The adobe_tools Module

This module provides a number of convenience functions for interacting with the [Adobe User Management API](https://www.adobe.io/products/usermanagement/docs/gettingstarted). You'll need to have the "usermanagement.config" and "private.key" files in place somewhere, as [documented on the API website](https://www.adobe.io/products/usermanagement/docs/samples#setup). The code as is written assumes they're located in `/Library/Adobe`, but you can move those files anywhere.

When using this module, the public functions will handle all appropriate config and setup necessary, and will provide the data without requiring anything else.  For example, to query whether or not a given user exists as a federated ID:
```
email = 'test@example.com'
result = adobe_tools.user_exists(email)
print result
```

## The add_adobe Script

This script is a one-stop shop for adding a user and providing them entitlements.

The entitlements are the names of the product configurations listed in your Adobe enterprise dashboard. You can also get the list of products from the module:
```
product_list = adobe_tools.get_product_list()
```

You must make sure that the `adobe_tools` module is in the Python path for this script.

Call this script with the product configuration you wish to add as an argument, and the following steps will happen:

* Does the user currently exist as a federated ID?
* If not, create a federated ID for this user.
* Does the user currently have the product entitlement?
* If not, add the product entitlement to this federated ID.

For example, to add the default After Effects product configuration:
```
$ add_adobe.py "Default After Effects CC - 0 GB Configuration"
```

Please note that this script, as written, requires you to fill in some details about how the user's email and federated ID is generated. If you have an LDAP / AD to query, you'll want to do that. If the usernames also match their email (i.e. "username@domain.com" is their valid email), that's also an easy way to add accounts. Best not to rely on the assumptions that were made to generalize it.
