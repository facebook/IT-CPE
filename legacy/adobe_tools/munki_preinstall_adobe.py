#!/usr/bin/python
# Copyright (c) Facebook, Inc. and its affiliates.
"""Check to see whether an Adobe entitlement has been added to the user."""

from __future__ import print_function
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
  tag = 'CPE-check_adobe'
  print (tag + ': %s' % str(message))


if email is None or email == '':
    # No user, could likely be root
    print("No email found for %s" % me.username)
    exit(0)

# Do I exist as a user?
user_exists = False
try:
    user_exists = adobe_tools.user_exists(email)
except Exception as e:
    log("EXCEPTION: %s" % e)
    # If any exceptions are generated, should assume not entitled
    exit(0)

if not user_exists:
    # User has no account, so obviously this isn't entitled
    log("User %s does not have an existing account." % email)
    exit(0)

# Does the user already have the product?
log("Checking to see if %s already has %s" % (email, target_product))
already_have = False
try:
    already_have = adobe_tools.does_user_have_product(target_product, email)
except Exception as e:
    log("EXCEPTION: %s" % e)
    # If any exceptions are generated, should assume not entitled
    exit(0)

if already_have:
    log("User %s already has product %s" % (email, target_product))
    exit(1)

log("Eligible to install %s." % target_product)
