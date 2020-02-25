#!/usr/bin/python
# Copyright (c) Facebook, Inc. and its affiliates.
"""Remove an Adobe entitlement from the user."""

import sys

import adobe_tools

target_product = sys.argv[1]

me = ldap_lookup()  # Replace this with your own user lookup method
email = me.email
firstname = me.first_name
lastname = me.last_name
country = 'US'


def log(message):
  """Log with tag."""
  tag = 'CPE-remove_adobe'
  print (tag + ': %s' % str(message))


if email is None or email == '':
    # No user, could likely be root
    exit(0)

result = adobe_tools.remove_products(target_product, email)
if not result:
    log("Removal of product %s from %s failed." % (target_product, email))
    exit(1)

log("Removed %s from %s's account" % (target_product, email))
