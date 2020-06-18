#!/usr/bin/env python3
# Copyright (c) Facebook, Inc. and its affiliates. All rights reserved.

import argparse
import logging
import os
from argparse import Namespace
from typing import Any, Dict

import cpe.pantri.lib.utils as utils
from cpe.pantri.lib.fb_objectstore import FB_ObjectStore
from cpe.pantri.lib.pantri import Pantri


def retrieve(options: Dict[str, Any]) -> None:

    # check if git repo was update before retrieving files.
    pantri = Pantri(options)
    if pantri.nothing_to_retrieve():
        logging.getLogger("pantri").info(
            "it-bin repo already up-to-date. " "Use -f/--force to override"
        )
        return

    # In order to selectively choose which shelves to retrieve and have
    # different options per shelf, need to call "pantri.retrieve()" for each
    # shelf.
    if "shelf" in options:
        for shelf in options["shelf"]:
            options["shelf"] = shelf

            pantri = Pantri(options)
            pantri.retrieve()
    else:
        pantri = Pantri(options)
        pantri.retrieve()


def store(options) -> None:
    pantri = Pantri(options)
    pantri.store()


def auth(options) -> bool:
    """Set up auth and nothing else."""
    objectStore = FB_ObjectStore(options)
    if options.get("test", False):
        # If we only care if it's valid, just check and leave
        auth_token = objectStore.get_cached_auth_token()
        # Validate and return cached auth token.
        if auth_token and objectStore.validate_auth_token(auth_token):
            logging.getLogger("pantri").info("Auth token is valid.")
            return True
        logging.getLogger("pantri").info("Auth token is invalid.")
        return False
    objectStore.get_auth_token()
    logging.getLogger("pantri").info("Auth token is valid.")
    return True


def get_options(args: Namespace) -> Dict[Any, Any]:
    """ Convert cli args into dictionary """
    options = {}
    for arg, value in vars(args).items():
        # Dont include the func arg and null values
        if arg != "func" and value:
            options.update({arg: value})

        # Add method name ie retrieve or store to options
        if arg == "func":
            options.update({"method": value.__name__})

    return options


def delete_json_output_files() -> None:
    # Remove update_objects file that might exist from previous run
    json_files = os.path.join(utils.get_paths()["scripts"], "*_updated_objects.json")
    utils.remove(json_files)


def main(context) -> int:
    # Define parser
    loglevel = logging.INFO
    logging_tools.setup_logging("pantri", loglevel, context, "pantri")
    logging.getLogger("pantri").info("Beginning Pantri...")

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--ignore_patterns",
        type=str,
        default=[],
        nargs="+",
        help="Files on disk to ignore uploading. Supports wildcard patterns.",
    )
    parser.add_argument(
        "--binary_overrides",
        type=str,
        default=[],
        nargs="+",
        help="Text files that should be treated as binaries."
        + "Supports wildcard patterns.",
    )
    parser.add_argument(
        "--itbin_path",
        type=str,
        help="Specify itbin path directly instead of using path in config file",
    )
    parser.add_argument(
        "-cs",
        "--checksum",
        action="store_true",
        dest="checksum",
        default=False,
        help="Use sha1 checksums to determine if files are different vs "
        + "file size and modified times",
    )
    parser.add_argument(
        "-p",
        "--password_file",
        action="store_true",
        dest="password_file",
        default=False,
        help="Use password file for auth",
    )

    # Define subparser for store and retrieve commands
    subparsers = parser.add_subparsers(dest="subcommand", help="commands")
    subparsers.required = True

    # auth subparser command
    parser_auth = subparsers.add_parser("auth")
    parser_auth.set_defaults(func=auth)
    parser_auth.add_argument(
        "--test",
        action="store_true",
        default=False,
        help="Only test that the token is valid, do not attempt to fetch a new one",
    )

    # store subparser command and flags
    parser_store = subparsers.add_parser("store")
    parser_store.add_argument(
        "objects",
        default=[],
        nargs="*",
        help="List of files or directories to store(upload)",
    )
    parser_store.set_defaults(func=store)

    # retrieve subparser command and flags
    parser_retrieve = subparsers.add_parser("retrieve")
    parser_retrieve.add_argument(
        "-s", "--shelf", type=str, default=[], nargs="*", help="Shelf(s) to retrieve"
    )
    parser_retrieve.add_argument(
        "-f",
        "--force",
        action="store_true",
        dest="force",
        default=False,
        help="Force syncing if repo is up-to-date",
    )
    parser_retrieve.add_argument(
        "-j",
        "--json_output",
        action="store_true",
        dest="json_output",
        default=False,
        help=(
            "Write status of updated objects to" " scripts/{shelf}_updated_objects.json"
        ),
    )
    parser_retrieve.add_argument(
        "-d", "--dest_sync", type=str, default=None, help="Location to sync files"
    )
    parser_retrieve.add_argument(
        "-i",
        "--pitem",
        type=str,
        dest="pitem",
        default=False,
        help="Use to retrieve one item",
    )

    # Retain the '-p' flag in the retrieve argparser instance to support existing
    # use-cases. The codebase should be searched for instances of 'retrieve -p'
    # and migrated to having the only the global argparse instance looking for
    # the '-p' flag.
    parser_retrieve.add_argument(
        "-p",
        "--password_file",
        action="store_true",
        dest="password_file",
        default=False,
        help="Use password file for auth",
    )
    parser_retrieve.set_defaults(func=retrieve)

    # Parse arguments
    args = parser.parse_args()

    # Build args into a dict
    options = get_options(args)
    if "itbin_path" in options:
        if os.path.exists(options["itbin_path"]):
            utils.create_conf(options["itbin_path"])
        else:
            logging.getLogger("pantri").error("itbin path does not exist.")
            raise OSError("Incorrect it-bin flag path.")

    # Given that multiple shelves can be retrieved, need to delete the updated
    # objects json file before Pantri.retrieve() is called.
    # Remove once task 13837440 is completed
    delete_json_output_files()

    # Run default functions defined for each command.
    result = args.func(options)
    if result is False:
        # If 'pantri auth --test' failed, return non-zero.
        return 1
    return 0


if __name__ == "__main__":
    main()
