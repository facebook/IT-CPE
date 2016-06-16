#  Copyright (c) 2015-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

"""Functions used to talk to the corporate network"""

import requests

import sys_tools


def check_corp_network():
    """
    check_corp_network()

    Check to see if machine is on the corp net
    """
    # NOTE: update interal.com to an internal website/ip
    return requests.get("http://internal.com").status_code == requests.codes.ok


def check_network(url=None):
    """
    check_network(url=None)

    Check to see if the connection is active.
    URL must have a leading http/https.
    """
    if not url:
        url = "https://facebook.com"
    try:
        requests.get(url, timeout=2)
        return True
    except:
        return False


def wait_for_corp():
    """
    wait_for_corp()

    Returns when connected to the corp net
    """
    while True:
        if check_corp_network():
            return
        else:
            sys_tools.sleep(secs=3)
