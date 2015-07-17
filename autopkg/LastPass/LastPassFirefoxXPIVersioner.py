#!/usr/bin/env python
#
#  Copyright (c) 2015, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

import xml.etree.ElementTree as ET
import os

from autopkglib import Processor, ProcessorError

__all__ = ["LastPassFirefoxXPIVersioner"]


class LastPassFirefoxXPIVersioner(Processor):
    description = "Parse the LastPass Firefox XPI's "\
                  "install.rdf for version information."
    input_variables = {
    }
    output_variables = {
        "version": {
            "description": "Version of the LastPass XPI."
        }
    }

    __doc__ = description

    def main(self):
        try:
            tree = ET.parse(os.path.join(
                            self.env['RECIPE_CACHE_DIR'],
                            'XPI_decompressed',
                            'install.rdf'))
        except IOError as err:
            raise ProcessorError(err)
        root = tree.getroot()
        # root[0][1].text = version information for install.rdf
        self.env['version'] = root[0][1].text
        self.output('Version found in install.rdf: %s' % self.env['version'])
        # end

if __name__ == '__main__':
    processor = LastPassFirefoxXPIVersioner()
    processor.execute_shell()
