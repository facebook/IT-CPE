#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

"""Functions for fetching info about the user's machine"""

import hashlib
import os
import re
import signal
import subprocess
import syslog
import time

import shell_tools
import sys_tools


def activate_application(app_name):
    """
    activate_application(app_name)
    """
    launch_app = """osascript<<END
    activate application "%s"
    END""" % (app_name)
    os.system(launch_app)


def create_local_account(user, full_name, password, admin=False, hidden=False):
    """
    create_local_account(user, full_name, password, admin=False)

    Creates a local account on the computer. If admin is True, This
    account will be able to administer the computer
    hiddden=True will only work if the "hide500users" is set to true in the
    loginwindow plist
    """
    dscl_command = "dscl ."
    home_dir = "/Users/%s" % user

    uids = shell_tools.run(
        "%s -list /Users UniqueID | awk \\'{print $2}\\'" % (dscl_command),
        sanitize=False
    )["stdout"].split()
    next_id = map(int, uids)
    next_id.sort()
    next_id = next_id[-1]

    # UIDs less than 500 are hidden, set it equal to 500 to be incremented
    if next_id < 500:
        if not hidden:
            next_id = 500

    # Increment by 1 for the next free UID
    user_id = next_id + 1

    # Create it manually as not to rely on casper
    create_user_commands = [
        "create %s" % home_dir,
        "create %s UserShell /bin/bash" % home_dir,
        "create %s RealName \\'%s\\'" % (home_dir, full_name),
        "create %s UniqueID %s" % (home_dir, user_id),
        "create %s PrimaryGroupID 1000" % home_dir,
        "create %s NFSHomeDirectory%s" % (home_dir, home_dir),
        "passwd %s \\'%s\\'" % (home_dir, password),
    ]
    if admin:
        create_user_commands.append(
            "append /Groups/admin GroupMembership %s" % user
        )

    for command in create_user_commands:
        shell_tools.run("%s %s" % (dscl_command, command))


def configure_time():
    """
    configure_time()

    Sync and enable to point to time_server variable
    """
    # Turn the time setting off to force use ntpdate to sync
    time_server = "time.apple.com"
    time_commands = [
        "systemsetup -setusingnetworktime off",
        "ntpdate %s" % time_server,
        "systemsetup -setusingnetworktime on",
        "systemsetup -setnetworktimeserver %s" % time_server,
    ]
    for command in time_commands:
        shell_tools.run(command)


def enough_space(required_space):
    """
    enough_space(required_space)

    Returns whether there is enough space on the root volume given
    the required_space
    """

    return True if get_free_hd_space("gigabytes") - required_space < 3 else False


def get_computer_name():
    """
    get_hostname()

    Returns the machine's hostname
    """
    return shell_tools.run("scutil --get ComputerName")["stdout"]


def get_model(short=False):
    """
    get_model(short=False)

    Returns the machine's hardware model
    """
    models = {
        "Mac Pro": "pro",
        "MacBook Air": "mba",
        "MacBook Pro": "mbp",
        "Mac mini": "mm",
        "iMac": "im"
    }

    model = query_profiler(
        "SPHardwareDataType", ["Hardware Overview", "Model Name"]
    )
    if short:
        # Default to mac when not found
        return models.get(model, "mac")
    else:
        return model


def get_os_version():
    """
    get_os_version()

    Returns the operating system version
    """
    return shell_tools.run("sw_vers -productVersion")["stdout"]


def get_serial():
    """
    get_serial()

    Returns the machine's serial number
    """
    return query_profiler(
        "SPHardwareDataType", ["Hardware Overview", "Serial Number (system)"]
    )


def get_shard(serial=None, salt=None, chunks=10):
    """
    get_shard(serial=None, salt=None, chunks=10)

    Returns the machine's unique shard number

    serial => Pass a serial for another machine to get its shard
    salt   => Pass a salt to generate the hash
    chunks => Pass an int to set number of chunks.
    """
    md5 = hashlib.md5()
    if not serial:
        serial = get_serial()
    if salt:
        serial = str(serial) + str(salt)
    md5.update(serial)
    digest = md5.hexdigest()
    number = int(digest, 16)
    shard = number % int(chunks)
    return shard


def get_total_memory():
    """
    get_total_memory()

    Returns the total memory in GBs
    """
    total_memory = shell_tools.run('sysctl -a | grep hw.memsize')['stdout']
    return (int(total_memory.split('=')[-1]) / (1024 * 3))


def get_time_since(time, mode="secs"):
    """
    get_time_since(time, mode="secs")

    Returns the time since in seconds
    mode options: year, weeks, days, hours, mins, secs
    """
    now = shell_tools.get_unix_time()
    unit = {
        'years': 365 * 86400,
        'weeks': 604800,
        'days': 86400,
        'hours': 3600,
        'mins': 60,
        'secs': 0,
    }
    since = now - time
    if unit[mode] == 0:
        return since
    return since / unit[mode]


def get_used_memory():
    """
    get_used_memory()

    Returns the machine's used memory in MB
    """
    get_top_memory = shell_tools.run(
        'top -l 1 | grep PhysMem')['stdout'].split()
    return get_top_memory[1]


def get_uptime():
    """
    get_uptime()

    Get system uptime in minutes.
    """
    boot_time = int(shell_tools.run(
        "sysctl -n kern.boottime")["stdout"].split()[3].strip(',')
    )
    return (shell_tools.get_unix_time() - boot_time) / 60


def query_profiler(
    data_type,
    path,
    needle=None,
    verbose=False,
    ending=True,
    numeric=False,
    periods=True,
):
    """
    query_profiler(data_type, path, needle=None, verbose=False,
                      ending=True, numeric=False, periods=True,)

    needle:   Needle to search for in haystack. Returns T/F and ignores
              other conditions. Use path=[]
    verbose:  Ending parenthesis and their contents if they exist.
    ending:   Last word. "160 GB" => "160".
    numeric:  All non-numeric chars.
    periods:  All periods. Exclusive of numeric option.

    Returns the value at the end of a path of keys.
    Try: "SPStorageDataType",
    ["Macintosh HD", "Physical Volumes", "disk0s2", "Size"]
    Options for keeping / removing part of the string. True = keep,
    False = remove.
   """
    output = subprocess.Popen(
        ["system_profiler", data_type], stdout=subprocess.PIPE).communicate()[0]
    path_index = 0
    if needle:
        return True if needle in output else False
    for line in output.splitlines():
        if line.strip().startswith(path[path_index]):
            if path_index >= len(path) - 1:
                # Return only the value. Ignore "key: ".
                value = line.strip()[len(path[path_index]) + 2:]
                if not verbose:
                    # Chop off ending content in parenthesis if it exists.
                    if value[-1] == ")":
                        value = value[:value.find("(") - 1]
                if not ending:
                    # Chop off last word of value.
                    value = value.rsplit(" ", 1)[0]

                if not periods:
                    # Remove all periods.
                    value = re.sub(r"\.", "", value)
                elif numeric:
                    # Remove non-numeric chars.
                    value = re.sub(r"\D", "", value)
                return value
            else:
                path_index += 1


def launchctl_load(name_of_daemon):
    """
    load_launch_daemon(name_of_daemon)

    Loads the launch daemon
    """
    shell_tools.run(
        "launchctl load -w %s/%s" %
        (sys_tools.get_sys_path('launchdaemons'), name_of_daemon)
    )


def launchctl_reload(name_of_daemon):
    """
    reload_launch_daemon(name_of_daemon)

    Unloads the daemon, waits one second, then loads the daemon
    """
    launchctl_unload(name_of_daemon)
    sleep(secs=1)
    launchctl_load(name_of_daemon)


def launchctl_unload(name_of_daemon):
    """
    unload_launch_daemon(name_of_daemon)

    Unloads the name of daemon
    """
    sleep(secs=3)
    shell_tools.run(
        "launchctl unload -w %s/%s" %
        (sys_tools.get_sys_path('launchdaemons'), name_of_daemon)
    )


def log(tag, message):
    """
    log(tag, message)

    Writes the tag and message to the syslog
    """
    syslog.openlog(tag)
    syslog.syslog(syslog.LOG_ALERT, message)


def logout():
    """
    logout()

    Logs the current user out of the GUI
    """
    logout = """osascript<<END
    tell application "System Events" to logout
    END"""
    os.system(logout)


def get_hd_capacity():
    """
    get_hd_capacity()

    Get the main HD's capacity in gigabtyes (float)
    """

    # Determine HD name
    hd_name = get_hd_name()

    return float(query_profiler(
        "SPStorageDataType", [hd_name, "Capacity"], ending=False)
    )


def get_free_hd_space(unit):
    """
    get_free_hd_space(unit)

    Get the main HD's free space in gigabytes, will convert to bytes, megabytes,
    or gigabytes if specified
    """
    gigabyte_size = 1024
    megabyte_size = 1048576

    # Determine HD name
    hd_name = get_hd_name()

    # Query_profiler returns free space in GB as a strig
    free_space = query_profiler(
        "SPStorageDataType", [hd_name, "Available"], ending=False)
    free_space = int(float(free_space))

    if unit == "gigabytes":
        return free_space
    if unit == "megabytes":
        return free_space * gigabyte_size
    if unit == "bytes":
        return (free_space * gigabyte_size) * megabyte_size


def get_hd_name():
    """
    get_hd_name()

    Returns the root hard drive name
    """

    hd_name = shell_tools.run(
        "diskutil info / | grep Volume | grep Name"
    )["stdout"].split()[2:]
    return " ".join(hd_name)


def get_hd_used_space():
    """
    get_hd_used_space()

    Returns the amount of space used on the machine (float)
    """
    capacity = float(get_hd_capacity())
    available = float(get_free_hd_space("gigabytes"))
    return capacity - available


def install_pkg(pkg, base_dir='/'):
    """
    install_pkg(pkg, base_dir='/')

    Use the installer utility to install packages in root(/) by default
    """

    install_cmd = '/usr/sbin/installer -pkg %s -target %s' % (pkg, base_dir)
    install_results = shell_tools.run(install_cmd)

    if not install_results['success']:
        raise Exception(install_results['stderr'], install_results['stdout'])


def is_process_running(process):
    """
    is_process_running(process)

    Checks to see if a process is running.
    """

    all_processes = os.popen("ps -Af").read()

    return True if process in all_processes else False


def is_desktop():
    """
    is_desktop():

    Returns whether or not the machines is a desktop
    """

    return True if not is_laptop() else False


def is_laptop():
    """
    is_laptop():

    Returns whether or not the machines is a laptop
    """

    return True if 'book' in get_model().lower() else False


def kill_process(pid):
    """
    kill_process(pid)

    Kills a process given a pid
    """

    try:
        os.kill(int(pid), signal.SIGKILL)
    except OSError:
        print "No process running."


def set_machine_name(hostname):
    """
    set_hostname(hostname)

    Sets the machine's hostname
    """

    shell_tools.run("scutil --set ComputerName %s" % hostname)
    shell_tools.run("scutil --set LocalHostName %s" % hostname)


def sleep(secs=None, mins=None, hrs=None, days=None):
    """
    sleep(secs=None, mins=None, hrs=None, days=None)

    Sleeps for a given duration
    """
    sleep_time = secs
    if mins:
        sleep_time = 60 * mins
    if hrs:
        sleep_time = 60 * 60 * hrs
    if days:
        sleep_time = 60 * 60 * 24 * days
    time.sleep(sleep_time)


def verify_hd_name():
    """
    verify_hd_name()

    Verify that the disk is named "Macintosh HD," otherwise rename it
    """
    if get_hd_name() != "Macintosh HD":
        shell_tools.run("diskutil rename / \"Macintosh\ HD\"")
