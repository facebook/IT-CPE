#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

import urllib2


def auth_init(theurl, username, password):
    """
    auth_init(theurl,username,password) initializes a password manager for APIs
    takes a baseurl, username and password, returns page content as string
    This can be parsed by element tree or minidom

    Ex.
    # Define the username, password and url we want to use
    theurl = 'https://casper.somedomain.com/JSSResource/computers'
    username='API_user'
    password='password_here'
    """
    try:
        passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
        passman.add_password(None, theurl, username, password)
        return urllib2.build_opener(urllib2.HTTPBasicAuthHandler(passman))
    except urllib2.HTTPError:
        raise Exception("Unable to authenticate!")
