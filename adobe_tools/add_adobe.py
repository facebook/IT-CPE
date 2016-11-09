#!/usr/bin/python
"""Add Adobe products to user on-demand."""

import sys

import adobe_tools

target_product = sys.argv[1]

# You should replace this code with your own way to determine
# who the current user is - such as an LDAP query
# or database lookup.
def getconsoleuser():
  """Get the current console user."""
  from SystemConfiguration import SCDynamicStoreCopyConsoleUser
  cfuser = SCDynamicStoreCopyConsoleUser(None, None, None)
  return cfuser[0]

me = getconsoleuser()
email = me + "@domain.com"
firstname = me
lastname = me
country = 'US'


def log(message):
  """Log with tag."""
  print 'CPE-add_adobe: ' + str(message)

# Do I exist as a user?
if not adobe_tools.user_exists(email):
  log("Creating account for %s" % email)
  # Add the user
  success = adobe_tools.add_user(email, firstname, lastname, country)
  if not success:
    log("Failed to create account for %s" % email)
    sys.exit(1)

# Does the user already have the product?
log("Checking to see if %s already has %s" % (email, target_product))
already_have = adobe_tools.does_user_have_product(email, target_product)
if already_have:
  log("User %s already has product %s" % (email, target_product))
  sys.exit(0)

# Add desired product
log("Adding %s entitlement to %s" % (target_product, email))
result = adobe_tools.add_products([target_product], email)
if not result:
  log("Failed to add product %s to %s" % (target_product, email))
  sys.exit(1)

log("Done.")
