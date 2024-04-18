#!/usr/local/munki/Python.framework/Versions/Current/bin/python3
# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

"""Munki preflight to configure Munki run settings."""

import os
import plistlib
import subprocess
import sys
import time
from pathlib import Path

MUNKI_PAUSE_TRIGGER = "/Users/Shared/.pause_munki"
MUNKI_PAUSE_RECEIPT = "/Library/CPE/tags/.munki_has_been_paused"


def check_munki_pause() -> None:
    # If the trigger is present, pause Munki for 24 hours
    if os.path.isfile(MUNKI_PAUSE_TRIGGER):
        # pyre-fixme[16]: `stat_result` has no attribute `st_birthtime`.
        creation_time = os.stat(MUNKI_PAUSE_TRIGGER).st_birthtime
        if int(time.time()) - int(creation_time) >= 86400:
            # If the pause file is older than 24 hours, kill it
            try:
                os.unlink(MUNKI_PAUSE_TRIGGER)
                print("Munki pause file is older than 24 hours, removing...")
                # Leave a receipt in the tags folder indicating pause was used
                Path(MUNKI_PAUSE_RECEIPT).touch()
            except Exception as e:
                print(f"Unable to unpause Munki: {e}")
        else:
            # Unload the force helper launchd
            unload_cmd = [
                "/bin/launchctl",
                "unload",
                "/Library/LaunchDaemons/com.googlecode.munki.logouthelper" + ".plist",
            ]
            results = subprocess.run(unload_cmd, capture_output=True)
            if results.returncode != 0:
                print(f"Unable to unload logouthelper: {results.stderr}")
            print("MSC is paused. Check the f-Menu to unpause.")
            sys.exit(1)

    # Clean up the pause receipt after 3 days
    if os.path.isfile(MUNKI_PAUSE_RECEIPT):
        creation_time = os.stat(MUNKI_PAUSE_RECEIPT).st_birthtime
        if int(time.time()) - int(creation_time) >= 259200:
            # If the pause receipt is older than 3 days, kill it
            try:
                os.unlink(MUNKI_PAUSE_RECEIPT)
                print("Cleaning up old pause receipt...")
            except Exception as e:
                print(f"Unable to clear pause receipt: {e}")


def get_airport_info() -> str:
    """Get the SSID of the connected WiFi network."""
    cmd = ["/usr/sbin/ioreg", "-r", "-k", "IO80211CountryCode", "-d", "1", "-a"]
    proc = subprocess.run(cmd, stdout=subprocess.PIPE)
    output = proc.stdout
    plist_output = plistlib.loads(output)[0]
    ssid = plist_output.get("IO80211SSID", "")
    return ssid


def exit_if_on_wifi_shuttle() -> None:
    wireless_ssid = get_airport_info()
    if wireless_ssid == "fbshuttle" or wireless_ssid == 'RIDEwifi':
        print("MSC will not run on shuttle wifi.")
        sys.exit(1)


def main() -> None:
    print("Gathering run data...")
    # Verify munki pause
    check_munki_pause()

    runtype: str = sys.argv[1]
    if runtype == "auto":
        exit_if_on_wifi_shuttle()

    print("Preflight completed successfully.")


if __name__ == "__main__":
    main()
