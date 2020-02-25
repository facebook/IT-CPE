#!/usr/bin/python
# Copyright (c) Facebook, Inc. and its affiliates.
"""Add Adobe products to user on-demand."""

import sys

import adobe_api
import adobe_tools

target_product = sys.argv[1]

me = ldap_lookup()  # Replace this with your own user lookup method
email = me.email
firstname = me.first_name
lastname = me.last_name
country = 'US'


def log(message):
try:
    # Do I exist as a user?
    if not adobe_tools.user_exists(email):
        log("Creating account for %s" % email)
        # Add the user
        success = adobe_tools.add_federated_user(
            email,
            email,
            firstname,
            lastname,
            country
        )
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
except adobe_api.AdobeAPIBadStatusException as e:
    log("Encountered exception: %s" % e)
    log(
        "You were most likely rate limited - "
        "this will automatically try again later. "
        "Alternatively, please contact Help Desk."
    )
    exit(1)
