#!/usr/bin/env python3
# Copyright (c) Facebook, Inc. and its affiliates. All rights reserved.

import logging
import logging.handlers
import os

from . import utils


def get_logger():
    """
  get_logger():

  Creates logger object to output messages to stdout
  """

    log_dir = os.path.join(utils.get_paths()["logs"])
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    log_path = os.path.join(log_dir, "pantri.log")
    logger = logging.getLogger(__name__)
    if not len(logger.handlers):
        format_str = "[%(asctime)s] %(levelname)s: %(message)s"

        # Define stdout handler
        console = logging.StreamHandler()
        console.setFormatter(logging.Formatter(format_str))

        # Define log handler
        log_file = logging.handlers.TimedRotatingFileHandler(
            log_path, when="midnight", interval=1, backupCount=14
        )
        # log_file = logging.FileHandler(log_path)
        log_file.setFormatter(logging.Formatter(format_str))

        # Add handlers
        logger.addHandler(console)
        logger.addHandler(log_file)
        logger.setLevel(logging.DEBUG)

    return logger
