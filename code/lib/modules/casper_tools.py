#  Copyright (c) 2015, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

"""Functions for interacting with Casper (locally and remotely)"""

import urllib2
import xml.dom.minidom

import api_tools
import shell_tools


def configure(username):
    """
    configure(ad_account)

    Basic jamf enrollment
    """
    shell_tools.run("jamf recon -realname '%s'" % username)


def flush_policies():
    """
    flush_policies()

    Flush all Casper policies. Requires root priviledges.
    """
    shell_tools.run("jamf flushPolicyHistory")


def get_casper_auth():
    """
    get_casper_auth()

    Enable interaction with the casper api, casper requires a BasicAuthHandler
    """
    username = ''
    password = ''
    top_level_url = ''

    return api_tools.auth_init(top_level_url, username, password)


def trigger_policy(policy):
    """
    trigger_policy(policy)

    Trigger a casper policy by passing the policy name
    """
    return shell_tools.run("jamf policy -trigger %s" % (policy))["success"]


def query_casper(resource, id=None, opener=None):
    """
    query_casper(resource, id=None, opener=None)

    Fetch and parse XML from Casper API
    Requires a resource and ID (see parse_network_segments for example)
    https://casper.somedomain.com/apiFrontPage.rest
    """
    if not opener:
        opener = get_casper_auth()
    urllib2.install_opener(opener)
    url = "https://casper.somedomain.com/JSSResource/%s" % (resource)
    if id:
        url += "/id/%s" % (id)
    try:
        return xml.dom.minidom.parse(urllib2.urlopen(url))
    except (urllib2.HTTPError, urllib2.URLError):
        return None
