#!/usr/bin/env python3
# Copyright (c) Facebook, Inc. and its affiliates. All rights reserved.
import logging
import os
import sys

from example_objectstore import Client as ExampleClient

from . import config, utils


class Example_ObjectStore(object):
    def __init__(self, options=None):
        """
        Instantiate class variables
        """

        if not options:
            options = config.getoptions("default", {})
        self.options = options
        self.logger = logging.getLogger("pantri")
        self.paths = utils.get_paths()
        self.git_path = self.paths["repo_root"]

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        return self

    def upload(self, objects_to_upload) -> None:
        self.logger.info("Storing into Example...")

        for obj in objects_to_upload:
            store_path = os.path.join(dir_path, obj)
            if self.example_store(store_path, obj):
                yield obj

    def example_store(self, obj_path, object) -> None:
        with self.client as client:
            object_to_store = os.path.join(self.paths["shelves"], object)
            if not client.exists(bucket, obj_path):
                self.make_example_dir(obj_path)

            with open(object_to_store, "rb") as file_to_put:
                try:
                    client.putAppend(bucket, path=obj_path, stream=file_to_put)
                    self.logger.info("Successfully stored %s into Example", object)
                    return True
                except StorageException:
                    self.logger.error(
                        "Storing %s into Example " "was unsuccessful", object
                    )

        return False

    def make_example_dir(self, path) -> None:
        with self.client as client:
            try:
                client.mkDirs(bucket, path=path)
            except BaseException:
                self.logger.error("Example Error: could not create directory.")
                sys.exit(1)

        return

    def retrieve(self, objects_to_sync) -> None:
        self.logger.info("Retrieving from Example...")

        objects = []
        for obj in objects_to_sync:
            objects.append(obj)

        with self.client as client:
            for obj in objects:
                object_path = os.path.join(self.options["dest_sync"], obj)
                path = os.path.join("tree", obj)
                with open(object_path, "wb") as f:
                    try:
                        client.get(bucket, path=path, stream=f)
                        self.logger.info("Downloaded file from example: %s", obj)
                        yield obj
                    except BaseException:
                        self.logger.error("File not found in example: %s", obj)

        return

    def has_valid_cert(self) -> bool:
        return True
