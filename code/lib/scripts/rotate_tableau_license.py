#!/usr/bin/python
#
#  Copyright (c) 2015, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

"""
This script provides several functions for interacting with the Tableau
licensing server. The two most important functions are the retire_license() and
activate_license() functions.
"""
import os
import subprocess

tableau_dir = '/Applications/Tableau.app/Contents'
cust_binary = "%s/Frameworks/FlexNet/custactutil" % tableau_dir
tableau_url = 'https://licensing.tableausoftware.com:443/flexnet'\
              '/services/ActivationService?wsdl'

tableau_key = 'REPLACE WITH YOUR TABLEAU KEY'


def activate_license(tableau_key):
    """
    activate_license(tableau_key)

    Activates the passed in license against the Tableau licensing server
    """
    # Apply the new license
    apply_new_license_cmd = "%s -served -comm soap -commServer "\
                            "%s -entitlementID %s" % (
                                cust_binary, tableau_url, tableau_key
                            )

    print "Activating new License"
    subprocess.call(apply_new_license_cmd, shell=True)


def get_installed_licenses():
    """
    get_installed_licenses()

    Executes the custactutil binary to get the active licenses on a system
    """
    installed_keys = subprocess.check_output(
        "%s -view" % cust_binary, shell=True
    )
    for line in installed_keys.split('\n'):
        if 'Fulfillment ID:' in line:
            return line.split()[2]

    return None


def install_flex_agent():
    """
    install_flex_agent()

    Installs the FlexNet licensing agent needed to activate/retire licenses
    """
    if not os.path.exists('/Library/Preferences/FLEXnet Publisher'):
        try:
            print 'Installing FLEXnet Licensing agent'
            subprocess.call(
                "/usr/sbin/installer -pkg %s/Installers"
                '/\"Tableau FLEXNet.pkg\" -target /'
                % tableau_dir, shell=True
            )
        except Exception as e:
            print "An error occured while installing FLEXnet: %s" % e
            raise


def retire_license(active_license):
    """
    retire_license(active_license)

    Loops through the licenses passed into the function and retires each one
    against the Tableau licensing servers
    """
    # Retire each ID
    retire_cmd = "%s -return %s -reason 1 -comm "\
        "soap -commServer %s" % (cust_binary, active_license, tableau_url)

    # Delete trial IDs, those cannot be retired
    if 'LOCAL_TRIAL_FID' in active_license:
        retire_cmd = "%s -delete %s" % (cust_binary, active_license)

    print "Retiring %s" % active_license
    subprocess.call(retire_cmd, shell=True)


if __name__ == '__main__':
    install_flex_agent()
    licenses = get_installed_licenses()
    if licenses:
        retire_license(licenses)
        activate_license(tableau_key)
