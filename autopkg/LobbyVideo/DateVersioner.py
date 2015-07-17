#!/usr/bin/env python
#
#  Copyright (c) 2015, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

import datetime
import time

from autopkglib import Processor

__all__ = ["DateVersioner"]


class DateVersioner(Processor):
    description = "Places current date and time into %version%."
    input_variables = {
        "notime": {
            "required": False,
            "description":
            ("True/false. If true, ",
             "only the current date is provided. Defaults to false.")
        }
    }
    output_variables = {
        "version": {
            "description": "Current date and time as version."
        }
    }

    __doc__ = description

    def main(self):
        try:
            notime = self.env["notime"]
        except KeyError:
            notime = False
            self.output("notime is %s" % notime)
        self.env["version"] = str(datetime.date.today()) + \
            '_' + str(time.strftime("%H-%M-%S"))
        if notime:
            self.env["version"] = str(datetime.date.today())
        self.output("Version is set to %s" % self.env["version"])

if __name__ == '__main__':
    processor = DateVersioner()
    processor.execute_shell()
