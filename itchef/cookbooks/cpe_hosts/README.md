cpe_hosts Cookbook
==================
This cookbook manages the /etc/hosts file.

Attributes
----------

* node['cpe_hosts']['extra_entries']
* node['cpe_hosts']['manage_by_line']

Usage
-----

### cpe_hosts::default

#### extra_entries
A map of IP addresses to hostnames which will be added to /etc/hosts.

When the default recipe is added to the run list it will add /etc/hosts entries
based on the contents of the `extra_entries` attribute.

For example, adding the following in some dependent cookbook:

  node.default['cpe_hosts']['extra_entries']['123.4.5.6'] = ['myaddress.com']

will create an entry in /etc/hosts like:

```
# /etc/hosts
...
123.4.5.6 myaddress.com # Chef Managed
```

#### manage_by_line
Option to manage entire file or by line.
