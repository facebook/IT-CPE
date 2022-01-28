#!/usr/bin/env fbpython

# Original: https://github.com/microsoft/vscode/issues/125666#issuecomment-1016945678
# Bug is in upstream: https://bugs.chromium.org/p/chromium/issues/detail?id=1238517
# Issue affects many statically built packages, notably:
# * VS Code @ FB - Insiders
# Mattermost
# Element
# Use those strings as parameters if they do not honor repeat rate in the normal way.
#
import json
import subprocess
import sys

if len(sys.argv) < 3:
    print(f"Usage {sys.argv[0]} repeats_per_second 'window 1' 'window 2'")
    sys.exit(1)

swaymsg = subprocess.Popen(
    ["swaymsg", "-t", "subscribe", "-m", '[ "window" ]'], stdout=subprocess.PIPE
)
target = int(sys.argv[1])
windows = sys.argv[2:]
prev = target
try:
    for line in swaymsg.stdout:
        j = json.loads(line)
        if j["container"]["app_id"] in windows:
            rate = 1000 // target
        else:
            rate = target
        if rate != prev:
            subprocess.run(
                ["swaymsg", f"input type:keyboard repeat_rate {rate}"], check=True
            )
            prev = rate


finally:
    swaymsg.kill()
