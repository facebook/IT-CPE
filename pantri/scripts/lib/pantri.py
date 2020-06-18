#!/usr/bin/env python3
# Copyright (c) Facebook, Inc. and its affiliates. All rights reserved.

import fnmatch
import getpass
import json
import logging
import os
import platform
import re
import sys
import time
from typing import Any, Dict

# Third party modules
import dirsync
import git

# from dsi.logger.py.LoggerConfigHandler import LoggerConfigHandler
from cpe.pyexec.modules import api_tools

from . import manifold  # noqa: F401
from . import config, utils
from .fb_objectstore import FB_ObjectStore


class Pantri(object):
    """
    Main class for Pantri
    """

    def __init__(self, cli_options=None):
        """
        __init__(self):

        Instantiate class variables
        """

        if cli_options is None:
            cli_options = {}

        self.logger = logging.getLogger("pantri")
        self.paths = utils.get_paths()
        self.git_path = self.paths["repo_root"]
        self.gitignore = self.read_gitignore()
        self.item_data = []

        # Get options from config
        self.shelf = "default"
        if "shelf" in cli_options:
            self.shelf = cli_options["shelf"]
        if "objects" in cli_options:
            self.shelf = utils.get_shelf_directory(cli_options["objects"])
        self.options = config.get_options(self.shelf, cli_options)

    def __del__(self):
        for data in self.item_data:
            api_tools.log_to_logger("CPEPantriRunsLoggerConfig", data)

        self.logger.info("Finished")

    def get_objects_to_upload(self, objects):
        """
        get_objects_to_upload(self, objects)

        Given a list of object paths, return a dictionary containing meatdata of
        file or files withi a directory.
        """
        expanded_objects = []
        objects_metadata = {}

        # Loop though objects to build list of all files to upload
        for obj in objects:
            # Use objects full path when building list of objects
            obj = utils.unix_path(os.path.abspath(obj))

            # Only upload objects within "shelves" directory
            if not obj.startswith((self.git_path)):
                self.logger.error(
                    "Object %s is not within %s " % (obj, self.paths["shelves"])
                )
                # TODO create exit functions and update all call sites
                sys.exit(1)

            # TODO create function to return list of files.
            # Build list of objects
            if os.path.isfile(obj):
                expanded_objects.append(obj)
            elif os.path.isdir(obj):
                for (root, _dirs, files) in os.walk(obj):
                    for f in files:
                        obj = os.path.join(root, f)
                        expanded_objects.append(obj)
            else:
                self.logger.warn("Local file '%s' not found" % obj)

            # Process list of object to calcuate file size, modified time and hash
        objects_metadata = self.process_objects(expanded_objects)
        return objects_metadata

    def process_objects(self, expanded_objects=None):
        """
        process_objects(expanded_objects)

        Given a list of objects, determines if uploadable (binary), and
        then create a dictionary of:
          sha1_hash
          sha256_hash
          modified_time
          filesize

        Sha1_hash is only determined on first upload or if modified time and
        file size changed.
        """

        if expanded_objects is None:
            expanded_objects = []

        objects_metadata = {}
        for obj in expanded_objects:
            # Process if object is uploadable
            if self.uploadable_object(obj):

                # Object name in metadata file. Replace \\ with / to remain consistent
                # accoss platforms
                object_name = utils.unix_path(
                    os.path.relpath(obj, self.paths["shelves"])
                )

                # Determine paths
                object_path = os.path.abspath(obj)
                object_metadata_file = "%s.pitem" % object_path

                # Add object to gitignore
                self.add_object_to_gitignore(obj)

                object_mtime = utils.get_modified_time(obj)
                object_file_size = utils.get_file_size(obj)
                # Use cached checksum since checksum hashing is cpu intensive and
                # file size and modified times are quicker. Checksums are force using
                # cli flag --checksum.
                if not self.options["checksum"] and os.path.exists(
                    object_metadata_file
                ):

                    with open(object_metadata_file) as json_file:
                        cached_metadata = json.load(json_file)

                    # Use cached hash if filesize and mtime are the same
                    if (
                        object_file_size == cached_metadata[object_name]["file_size"]
                        and object_mtime
                        == cached_metadata[object_name]["modified_time"]
                    ):

                        object_sha1_hash = cached_metadata[object_name]["sha1_hash"]
                        if "sha26_hash" in cached_metadata[object_name]:
                            cryp = "sha256_hash"
                            obj = object_name
                            object_sha256_hash = cached_metadata[obj][cryp]
                        else:
                            object_sha256_hash = utils.get_sha256(obj)
                    else:
                        object_sha1_hash = utils.get_sha1(obj)
                        object_sha256_hash = utils.get_sha256(obj)
                else:
                    # Genertate hash if cached_metadat is not present
                    object_sha1_hash = utils.get_sha1(obj)
                    object_sha256_hash = utils.get_sha256(obj)

                # Add object to metadata dictionary
                objects_metadata[object_name] = {
                    "sha1_hash": object_sha1_hash,
                    "sha256_hash": object_sha256_hash,
                    "modified_time": object_mtime,
                    "file_size": object_file_size,
                }

        return objects_metadata

    def get_uploaded_objects(self):
        """
        get_uploaded_objects(self)

        Walk though git repo and build one giant dictionary of uploaded objects
        """
        uploaded_objects = {}

        # Default sync is all directories under shelves unless specified
        shelf = self.paths["shelves"]
        if "shelf" in self.options:
            shelf = os.path.join(shelf, self.options["shelf"])

        # TODO create function to get list of files
        # Loop though all files to determine which files where uploaded.
        for (root, _dirs, files) in os.walk(shelf):
            for f in files:
                obj = os.path.join(root, f)
                filename = os.path.basename(obj)

                # Only care about *.pitem files
                if re.match("^.*.pitem$", filename):
                    with open(obj) as json_file:
                        uploaded_objects.update(json.load(json_file))

        return uploaded_objects

    def get_objects_on_disk(self):
        """
        get_objects_on_disk(self)

        Walk though local storage and build one giant dictionary of objects on disk
        """

        objects_on_disk = {}
        download_path = self.options["dest_sync"]
        if "shelf" in self.options:
            download_path = os.path.join(download_path, self.options["shelf"])

        for (root, _dirs, files) in os.walk(download_path):
            for f in files:
                obj = os.path.join(root, f)
                object_name = utils.unix_path(
                    os.path.relpath(obj, self.options["dest_sync"])
                )
                # Return sha1 hash if checksum is enabled
                if self.options["checksum"]:
                    objects_on_disk.update(
                        {object_name: {"sha1_hash": utils.get_sha1(obj)}}
                    )
                else:
                    objects_on_disk.update(
                        {
                            object_name: {
                                "modified_time": utils.get_modified_time(obj),
                                "file_size": utils.get_file_size(obj),
                            }
                        }
                    )

        return objects_on_disk

    def sync_local_files(self):
        """
        Sync non-binary files in source to dest_path
        """

        # Define source and destination paths
        src_path = self.paths["shelves"]
        dest_path = self.options["dest_sync"]
        if "shelf" in self.options:
            src_path = os.path.join(src_path, self.options["shelf"])
            dest_path = os.path.join(dest_path, self.options["shelf"])

        # Sync if paths dont match. No need to sync on top of the same path.
        if not src_path == dest_path:
            dirsync.sync(
                src_path,
                dest_path,
                "sync",
                logger=self.logger,
                create=True,
                verbose=True,
                exclude=["^.*.pitem$"],
            )

    def get_objects_to_retrieve(self):
        if "pitem" in self.options:
            if os.path.exists(self.options["pitem"]):
                try:
                    with open(self.options["pitem"]) as json_file:
                        item = json.load(json_file)
                    uploaded_objects = item
                    dl_path = os.path.join(self.paths["repo_root"], "shelves")
                    self.options["dest_sync"] = dl_path
                except Exception:
                    self.logger.error("Not a .pitem")
                    raise Exception("Did not specify a proper .pitem during retrieval")
            else:
                self.logger.error("Path to retrieval item does not exist.")
                raise OSError("Retrieval path doesn't exist.")
        else:
            uploaded_objects = self.get_uploaded_objects()
        objects_on_disk = self.get_objects_on_disk()

        # Compare upload object and objects on disk. Download missing files
        objects_to_retrieve = {}
        for obj in uploaded_objects:
            if obj not in objects_on_disk:
                self.logger.info("Download Object: %s (Object not present)" % obj)
                # Build dictionary of objects to download
                objects_to_retrieve.update({obj: uploaded_objects[obj]})
                continue

            # Compare sha1 hashes if checksum is enabled
            if (
                self.options["checksum"]
                and objects_on_disk[obj]["sha1_hash"]
                == uploaded_objects[obj]["sha1_hash"]
            ):

                self.logger.info("Skip Object: %s (matching hash)" % obj)
                continue

            # Check file size and modified times
            if (
                objects_on_disk[obj]["file_size"] == uploaded_objects[obj]["file_size"]
                and objects_on_disk[obj]["modified_time"]
                == uploaded_objects[obj]["modified_time"]
            ):

                self.logger.info(
                    "Skip Object: %s (matching file size and modified time.)" % obj
                )
                continue

            # Build dictionary of objects to download
            self.logger.info("Download Object: %s (object different)" % obj)
            objects_to_retrieve.update({obj: uploaded_objects[obj]})

        return objects_to_retrieve

    def get_objects_to_delete(self):
        """
        get_objects_to_delete()

        Return a list of files removed from git repo between pulls
        """

        # changed_files returns a tulple of (added, modified, deleted)
        deleted_files = utils.changed_files()[2]
        objects_to_delete = []
        for obj in deleted_files:
            # Delete files within shelves dir only.
            if not obj.startswith("shelves"):
                continue

            # Git returns the relative path of updated objects from git root.
            # Build object full path using repo_root path
            obj_path = os.path.join(self.paths["repo_root"], obj)

            # Determine object path within "shelves" directory
            obj_shelves_path = os.path.relpath(obj_path, self.paths["shelves"])

            # Build sync path
            obj_dest_path = os.path.join(self.paths["dest_sync"], obj_shelves_path)

            # Remove pitem from deletes to actually delete the binary file.
            if obj_dest_path.endswith("pitem"):
                obj_dest_path = os.path.splitext(obj_dest_path)[0]

            # Append objects to delete
            objects_to_delete.append(obj_dest_path)

        return objects_to_delete

    def nothing_to_retrieve(self):

        # Verify git config options are set and the auth token exists
        self.configure()

        try:
            git_pull = git.cmd.Git(self.paths["repo_root"]).pull()
        except git.exc.GitCommandError as e:
            self.logger.error(
                "Git pull failed. Please be on master"
                f" or set your upstream to master: {e}."
            )
            raise

        # perform a retrieve if the force flag is passed or retrieve a single pitem
        if "force" in self.options or "pitem" in self.options:
            return False

        if re.match("^Already up-to-date.$", git_pull):
            return True

        return False

    def retrieve(self):
        """
        retrieve(self)

        Compares files uploaded(json files in git) to objects already on disk
        to determine which files to download. File on disk that are not in git are
        removed.
        """
        self.logger.info("Beginning to retrieve files.")

        objects_to_delete = []
        if "pitem" not in self.options:
            # Sync non-binary files in shelves to dest_sync
            self.sync_local_files()

            # Delete objects in dest_sync on disk
            objects_to_delete = self.get_objects_to_delete()
            if objects_to_delete:
                utils.remove(objects_to_delete)

        # Download objects
        objects_to_retrieve = self.get_objects_to_retrieve()

        verify_retrieve = []
        if objects_to_retrieve:
            module = self.use_objectstore(self.options["object_store"])
            with module(self.options) as objectstore:
                for obj in objectstore.retrieve(objects_to_retrieve):
                    verify_retrieve.append(obj)
        else:
            self.logger.info("Repo up-to-date. No files to retrieve.")

        self.build_itemdata(objects_to_retrieve, verify_retrieve)

        self.write_updated_objects_to_file(objects_to_retrieve, objects_to_delete)

    def write_updated_objects_to_file(self, objects_retrieved, objects_removed):

        # Default json
        updated_objects = {"retrieved": [], "removed": []}

        # object_retrieve is a dict. Loop though and build full path and append
        for obj in objects_retrieved:
            obj_abs_path = os.path.join(self.paths["dest_sync"], obj)
            updated_objects["retrieved"].append(obj_abs_path)

        # objects_removed is an array. Extend array
        updated_objects["removed"].extend(objects_removed)

        # Write updated_objects file to disk
        filename = "%s_updated_objects.json" % self.shelf
        if self.shelf == "default":
            filename = "all_updated_objects.json"

        updated_objects_path = os.path.join(self.paths["scripts"], filename)
        utils.write_json_file(updated_objects_path, updated_objects)

    def configure(self):
        """Verifies local git settings and auth token exists"""

        # Verify ignorecase config is set for it-bin repo
        git_config = utils.read_file(self.paths["git_config"])
        if not re.search("ignorecase\s=\strue", git_config):
            cwd = os.path.join(utils.get_paths()["repo_root"], ".git")
            utils.run(["git", "config", "--local", "core.ignorecase", "true"], cwd)

        # Verify auth token is present.
        FB_ObjectStore(self.options).get_auth_token()

    def store(self):

        # Verify git config options are set and the auth token exists
        self.configure()

        self.logger.info("Beginning to upload files.")
        objects = self.options["objects"]
        # Generate list of objects to store(upload)
        objects_to_upload = self.get_objects_to_upload(objects)

        # TODO consider when this should be written to disk.
        # Update which files to exclude.
        self.write_gitignore()

        module = self.use_objectstore(self.options["object_store"])

        verify_upload = []
        with module(self.options) as objectstore:
            for obj in objectstore.upload(objects_to_upload):
                if obj in objects_to_upload:
                    verify_upload.append(obj)
                    self.write_diff_file({obj: objects_to_upload[obj]})

        self.build_itemdata(objects_to_upload, verify_upload)

        if len(verify_upload) != len(objects_to_upload):
            unsuccessful_obj = objects_to_upload.keys() - verify_upload
            self.logger.error(
                "Unsuccessful uploads: \n" + ("\n".join(map(str, unsuccessful_obj)))
            )
            sys.exit(-1)

    def uploadable_object(self, obj):
        """
        uploadable_obect(obj)

        Given an object, deterine if an object should be uploaded to object store.
        Uploadable object is defined as a binary that doesnt "ignore_patterns"
        listed in config.
        """

        # Exclude generated files.
        filename = os.path.basename(obj)
        if re.match("^.*.pitem$", filename):
            return False

        # Exclude files that match patten defined in config. ie, "*.pyc"
        for pattern in self.options["ignore_patterns"]:
            if fnmatch.fnmatch(filename, pattern):
                return False

        # Binary overrides match patten defined in config. ie, "*.pyc"
        for pattern in self.options["binary_overrides"]:
            if fnmatch.fnmatch(filename, pattern):
                return True

        # Binary check
        object_path = os.path.abspath(obj)
        if utils.is_binary(object_path):
            return True
        return False

    def add_object_to_gitignore(self, obj):
        """
        Determine extension or full path to add to gitignore
        """

        # TODO making a lot of assumptions when making this list. Need to improve
        # Build list of upload-able items to add to gitignore.
        rel_obj_path = os.path.relpath(obj, self.git_path)
        filename, file_ext = os.path.splitext(rel_obj_path)

        # Add extension or full path to gitignore
        if file_ext and re.match("^.[a-z]+$", file_ext, re.IGNORECASE):
            ext = "*" + file_ext.lower()
            if ext not in self.gitignore:
                self.gitignore.append(ext)
        else:
            if rel_obj_path not in self.gitignore:
                self.gitignore.append(rel_obj_path)

    def write_diff_file(self, object_metadata):
        """
        write_diff_file(self, object_metadata)

        Write json file contain metadata about a object.
        """

        # Write diff file to git repo
        path, filename = os.path.split(
            os.path.join(self.paths["shelves"], list(object_metadata.keys())[0])
        )
        diff_file = "%s/%s.pitem" % (path, filename)
        utils.write_json_file(diff_file, object_metadata)

    def read_gitignore(self):
        """
        Read contents of .gitignore
        """
        gitignore_path = self.paths["git_ignore"]
        gitignore = utils.read_file(gitignore_path).rstrip().split("\n")

        return gitignore

    def write_gitignore(self):
        """
        Exclude binary files uploaded to object store.
        """

        contents = ""
        # Loop though list, sort, and remove deplicates
        for item in sorted(set(self.gitignore)):
            contents += item + "\n"

        for path in [self.paths["git_ignore"], self.paths["git_exclude"]]:
            utils.write_file(path, contents)

    def use_objectstore(self, name):
        components = name.split(".")
        mod = __import__(components[0])
        for comp in components[1:]:
            try:
                mod = getattr(mod, comp)
            except BaseException:
                self.logger.error("Incorrect objectstore: %s", name)
                raise BaseException("Not a valid objectstore")

        self.logger.info("Using %s object store", mod)
        return mod

    def build_itemdata(self, total_objects, successful_objects):
        """
        Build the payload data for every item
        """
        for item in total_objects:
            success = 0
            if item in successful_objects:
                success = 1

            shelf = item.split(os.sep)[0]
            mod_time = total_objects[item]["modified_time"]

            data = self.build_payload(
                self.options["method"],
                item,
                str(self.options["object_store"]),
                shelf,
                success,
                str(total_objects[item]["sha1_hash"]),
                time.strftime("%Y-%m-%d %H:%M:%S %z", time.gmtime(mod_time)),
                total_objects[item]["file_size"],
                log_url=None,
                arguments=None,
            )
            self.item_data.append(data)

    def build_payload(
        self,
        command,
        object_name,
        object_store,
        shelf,
        return_code,
        checksum,
        date_modified,
        filesize,
        log_url,
        arguments,
    ):
        """
        Build a dictionary representing the item data for logging
        """
        json_dict = {}  # type: Dict[str, Any]
        json_dict["unixname"] = getpass.getuser()
        json_dict["command"] = command
        json_dict["object_name"] = object_name

        if "FB" in object_store:
            json_dict["object_store"] = "Swift"
        else:
            json_dict["object_store"] = "Manifold"

        json_dict["shelf"] = shelf
        json_dict["return_code"] = return_code
        json_dict["checksum"] = checksum
        json_dict["date_modified"] = date_modified
        json_dict["filesize"] = filesize
        json_dict["verbose_log_url"] = log_url
        json_dict["arguments"] = arguments
        json_dict["host_name"] = platform.node()

        return json_dict
