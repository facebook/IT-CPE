#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

"""Functions for interacting with command line utilities"""

import time

import envoy


def sanitize_output(text):
    """
    sanitize_output(text)

    Return a stripped string without newlines
    """
    return text.strip().replace("\n", "").replace("\r", "")


def run(command, sanitize=True):
    """
    run(command, sanitize=True)

    Runs the passed command and returns a dict of stdout (string),
    stderr (string), status (exit code - int)
    and success (bool - true if the exit code of 0)
    """
    result = envoy.run(command)
    result_dict = {
        "stdout": sanitize_output(result.std_out) if sanitize else result.std_out,
        "stderr": sanitize_output(result.std_err) if sanitize else result.std_err,
        "status": result.status_code,
        "success": True if result.status_code == 0 else False
    }
    return result_dict


def get_unix_time():
    """
    get_unix_time()

    Get current Unix timestamp as an int
    """
    return int(time.time())
