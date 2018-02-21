#!/usr/bin/env python2
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import platform


class PyexecWrongPlatformException(Exception):
    """Platform-specific code executed on wrong platform."""
    __slots__ = (
        'expected_platforms',  # list of str
        'function',  # str
    )

    def __init__(self, expected_platforms, fname=None):
        if isinstance(expected_platforms, list):
            self.expected_platforms = expected_platforms
        else:
            self.expected_platforms = [expected_platforms]
        self.function = fname

    def __str__(self):
        return "Function {} is {}-only, called on {}".format(
            self.function,
            " or ".join(self.expected_platforms),
            platform.system()
        )


SILENT_EXCEPTIONS = ()
