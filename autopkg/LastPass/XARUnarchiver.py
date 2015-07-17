#!/usr/bin/env python
#
#  Copyright (c) 2015, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

import subprocess

from autopkglib import Processor, ProcessorError

__all__ = ["XARUnarchiver"]


class XARUnarchiver(Processor):
    description = "Extracts a XAR archive."
    input_variables = {
        "archive": {
            "required": True,
            "description": "Path to the XAR archive."
        },
        "output_dir": {
            "required": False,
            "description": ("Path to desired output directory.",
                            " Defaults to %RECIPE_CACHE_DIR%.")
        }
    }
    output_variables = {
    }

    __doc__ = description

    def main(self):
        try:
            output_location = self.env["output_dir"]
        except KeyError:
            output_location = self.env["RECIPE_CACHE_DIR"]
        cmd = ['/usr/bin/xar', '-t', '-f', self.env["archive"]]
        proc = subprocess.Popen(cmd,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        (out, err) = proc.communicate()
        if err:
            raise ProcessorError(err)
        # first line of the safari extension contains its location
        cmd = ['/usr/bin/xar', '-x', '-f',
               self.env["archive"], '-C', output_location]
        proc = subprocess.Popen(cmd,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        (out, err) = proc.communicate()
        if err:
            raise ProcessorError(err)
        self.output("Extracted path at %s" % output_location)

if __name__ == '__main__':
    processor = XARUnarchiver()
    processor.execute_shell()
