#!/usr/bin/env python2
"""Shell tools functions."""

from __future__ import absolute_import
from __future__ import division
from __future__ import unicode_literals
from __future__ import print_function

import envoy
import logging
import sys
import subprocess

try:
    basestring
except NameError:
    basestring = str


def is_linux():
    return sys.platform.lower().startswith('linux')


def is_mac():
    return sys.platform.lower() == 'darwin'

"""Functions for running subprocesses for other Python modules"""


def sanitize_output(text):
    # Return a stripped string without newlines
    return text.strip().replace("\n", "").replace("\r", "")


def run_deprecated(command, sanitize=True):
    """
    run_deprecated(command, sanitize=True)

    Runs a command, returns a dict of info about it
    We're basically duplicating the Response object as a dict
    in case we decide to not use envoy in the future.
    It also lets us sanitize the output, which we usually want
    and is easier to reference in the future.
    """
    result = envoy.run(command)
    result_dict = {
        "stdout": sanitize_output(result.std_out)
        if sanitize else result.std_out,  # NOQA
        "stderr": sanitize_output(result.std_err)
        if sanitize else result.std_err,  # NOQA
        "status": result.status_code,
        "success": True if result.status_code == 0 else False
    }
    return result_dict


def run_subp(command, stdinput=None):
    """Run a subprocess.

    Args:
        command (list): Command to execute via subprocess.
        stdinput (str): Input to be sent to stdin.
    Returns:
        A dictionary containing stdout, stderr, the return code, and a bool
          indicating exit success.
    Raises:
        TypeError: If command is not an array.
    """
    # Validate that command is not a string
    if isinstance(command, basestring):
        # Not an array!
        raise TypeError('Command must be an array')
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        stdin=subprocess.PIPE
    )
    (out, err) = proc.communicate(stdinput)
    result_dict = {
        "stdout": out,
        "stderr": err,
        "status": proc.returncode,
        "success": True if proc.returncode == 0 else False
    }
    return result_dict


def run_live(command, redirect=None):
    """Run a subprocess with real-time output.

    Can optionally redirect stdout+stderr to a logger.
    Args:
        command (list): Command to execute via subprocess.
        redirect (logging.LEVEL): If set to None, this will print to stdout;
            otherwise will be logged to level specified.
    Returns:
        Returns the return-code of the subprocess.
    Raises:
        TypeError: If command is not an array.
    """
    if not isinstance(command, list):
        # Not an array!
        raise TypeError('Command must be an array')
    if redirect:
        return run_log(command, loglevel=redirect)
    # Run the command
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT
    )
    while proc.poll() is None:
        line = proc.stdout.readline()
        print(line, end='')
    print(proc.stdout.read())
    return proc.returncode


def run_log(command, cmd_name=None, loglevel=logging.INFO):
    """Run a subprocess with all output logged to a logger.

    Args:
        command (list): Command to execute via subprocess.
        cmd_name (str): A cosmetic name to output in logs. Defaults to
            command[0].
        loglevel (logging.LEVEL): Log level to use, defaults to INFO.
    Returns:
        Returns the return-code of the subprocess.
    Raises:
        TypeError: If command is not an array.
    """
    if not isinstance(command, list):
        # Not an array!
        raise TypeError('Command must be an array')
    name = command[0]
    if cmd_name:
        name = cmd_name
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT
    )
    with proc.stdout:
        log_subprocess_output(proc.stdout, name, loglevel)
    returncode = proc.wait()
    return returncode


def log_subprocess_output(pipe, cmd_name, loglevel=logging.INFO):
    """Log a stream pipe to a logger.

    Args:
        pipe (subprocess.PIPE): Stream pipe to read from.
        cmd_name (str): Name of command to use in log output.
        loglevel (logging.LEVEL): Log level to use, defaults to INFO.
    """
    for line in iter(pipe.readline, b''):
        logging.log(loglevel, '{0}: {1!r}'.format(cmd_name, line.rstrip()))
