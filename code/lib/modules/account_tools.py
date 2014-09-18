#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

"""Functions for interacting with Active Directory and local accounts"""

import casper_tools
import config
import shell_tools
import sys_tools


def bind_to_ad(loaner=False, hostname=None):
    """
    bind_to_ad()

    Bind the machine to Active Directory
    Unbinds if bound, then binds machine to Active Directory
    """
    def __bind():
        return shell_tools.run("""
      dsconfigad -f -a %s -u "%s" -p %s -domain %s -ou %s,%s
    """ % (bind_name[:13], config.LDAP_USER, config.LDAP_PASSWORD,
           config.BIND_DOMAIN, config.BIND_OU, config.BIND_DC))

    # If we're bound to AD...unbind from AD before rebinding
    shell_tools.run(
        "dsconfigad -f -r -force -u '%s' -p '%s'"
        % (config.LDAP_USER, config.LDAP_PASSWORD)
    )

    # Set the time before binding because process relies on synced time
    # between the client and the AD server
    sys_tools.configure_time()
    bind_name = sys_tools.get_computer_name()

    if hostname:
        bind_name = hostname

    bind = __bind()
    if bind['status'] == 70:
        sys_tools.log("account_tools-bind_to_ad", "Restarting opendirectoryd")
        shell_tools.run("killall opendirectoryd")
        sys_tools.sleep(secs=3)
        bind = __bind()

    if not bind['success']:
        sys_tools.log("account_tools-bind_to_ad", "Unable to bind to AD")
        raise Exception("Unable to bind to Active Directory")

    # Set additional AD settings
    bind_settings = [
        "dsconfigad -mobile enable",
        "dsconfigad -mobileconfirm disable",
    ]

    for setting in bind_settings:
        shell_tools.run("%s" % setting)


def create_mobile_account(ad_account):
    """
    create_mobile_account()

    Create a mobile managed AD account for the ad_account
    """

    managed_app = "/System/Library/CoreServices/ManagedClient.app/"
    unix_cma = "Contents/Resources/createmobileaccount"
    shell_tools.run("%s%s -n %s" % (managed_app, unix_cma, ad_account))
    make_admin(ad_account)


def flush_ad_cache():
    """
    flush_ad_cache()

    Flush the local AD cache
    """
    shell_tools.run("dscacheutil -flushcache")


def is_bound_to_ad():
    """
    is_bound_to_ad()

    Return the machine's AD bind status
    """
    # Flush cache first
    flush_ad_cache()
    # NOTE: Replace an_ad_user with an AD account that will never be deleted
    return shell_tools.run("id an_ad_user")['success']


def make_admin(username):
    """
    make_admin()

    Add user to the admin group
    """

    dscl_base = "dscl . -append /Local/Default/Groups"
    admin_commands = [
        "/admin GroupMembership",
        "/staff GroupMembership",
        "/_lpadmin GroupMembership",
    ]

    for command in admin_commands:
        shell_tools.run("%s%s %s" % (dscl_base, command, username))


def trigger_casper_ad_bind():
    """
    trigger_casper_ad_bind()

    Binds the machine via a casper AD bind trigger
    """
    return casper_tools.trigger_policy("your_casper_bind_trigger")
