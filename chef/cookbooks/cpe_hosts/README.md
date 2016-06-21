cpe_hosts Cookbook
----------------
This cookbook mananges hosts in the /etc/hosts file between the
tags `#Start-Managed-CPE-Hosts` and `#End-Managed-CPE-Hosts`.

Attributes
----------

* default['cpe_hosts']['extra_entries']
 * A map of IP addresses to hostnames which will be added to /etc/hosts.

Usage
-----

#### cpe_hosts::default

When the default recipe is added to the run list it will add /etc/hosts entries
based on the contents of the `extra_entries` attribute.

For example, adding the following in some depenedent cookbook:

  node.default['cpe_hosts']['extra_entries']['123.4.5.6'] = ['myaddress.com']

will create an entry in /etc/hosts like:

  # /etc/hosts
  ...
  #Start-CPE-Managed-Hosts
  127.0.0.1 home
  #End-CPE-Managed-Hosts
