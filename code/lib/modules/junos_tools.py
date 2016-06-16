#  Copyright (c) 2015-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

import os
import sys

import shell_tools
import sys_tools


def is_active():
    """
    is_active()

    Returns whether or not the JunosPulse interface is enabled
    """
    return shell_tools.run('route get facebook.com | grep utn')['success']


def is_junos_installed():
    """
    is_junos_installed()

    Checks for the app in /Applications
    """
    return os.path.exists('/Applications/Junos Pulse.app')


def import_junos_configuration(config_file):
    """
    import_junos_configuration(config)

    Imports the junos config_file
    """

    jam_path = "/Applications/Junos Pulse.app/Contents/Plugins/JamUI/jamCommand"

    # Import the selected junos configuration file
    import_config = shell_tools.run(
        '%s -importFile %s' % (jam_path, config_file))

    if not import_config["success"]:
        raise Exception("Unable to import config %s" % import_config["stderr"])

    # Kill the PulseTray to show the new configuration
    shell_tools.run("killall PulseTray")


def uninstall_junos(save_config=False):
    """
    uninstall_junos(save_config=False)

    Uninstall JunosPulse, optionally save the configuration files
    """
    uninstall_path = "/Library/Application Support/Juniper Networks/Junos Pulse"
    "Uninstall.app/Contents/Resources/uninstall.sh"

    # Do not continue if uninstall script doesnt exists
    assert not os.path.exists(uninstall_path), "Error: Junos does not exist"

    uninstall_base_command = "sh %s" % uninstall_path
    if not save_config:
        uninstall_base_command = uninstall_base_command + " 0"

    shell_tools.run(uninstall_base_command)


def wait_until_off_vpn():
    """
    wait_until_off_vpn()

    Will wait for junos to not be active, checks every 5 minutes for 9hrs
    """
    count = 0

    # Loop until junos is not active 108 times * 5 minutes = 9 hrs
    while count < 108:
        if is_active():
            print "Junos is active, waiting 5 minutes"
            count += 1
            sys_tools.sleep(mins=5)

            if count == 108:
                print "Junos timeout hit"
                sys.exit(0)
        break
