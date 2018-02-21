#!/usr/bin/env python2

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import argparse
import logging

import cpe.pyexec.modules.logging_tools as logging_tools
import cpe.pyexec.mm.update as update

# We use this in the log output for easier parsing
COMMAND_NAME = 'mm'


def main(context):
    """Main magic."""
    logging_tools.setup_logging(COMMAND_NAME, logging.INFO, context)
    parser = argparse.ArgumentParser(
        description='Manage the software deployment tools.'
    )
    # Normal arguments
    parser.add_argument(
        '-v', '--verbose', action='store_true', help='Print verbose messages.'
    )
    # Now add subparsers for the commands we care about
    subparsers = parser.add_subparsers(dest='cmd', help='sub-command help')
    # "update" command
    update_parser = subparsers.add_parser(
        'update',
        help='Update software in MSC',
    )
    update.add_argparser(update_parser)
    args = parser.parse_args()
    logging.debug(args)
    # Call the function defined by the subparser
    args.func(args)
    return 0


if __name__ == '__main__':
    logging_tools.run_main(COMMAND_NAME, main)
