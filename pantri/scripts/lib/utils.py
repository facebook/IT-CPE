# Copyright (c) Facebook, Inc. and its affiliates. All rights reserved.
# Utility functions.
import getpass
import glob
import hashlib
import json
import os
import platform
import re
import shutil
import subprocess

# Third party modules
import git


def run(cmd, cwd=None, sanitize=True):
    """
  Quick clone of shell_tools.run.

  TODO: Improve error handling
  """

    # Setting cwd within the repo
    if not cwd:
        cwd = os.path.dirname(os.path.realpath(__file__))

    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, cwd=cwd)
    stdout, stderr = p.communicate()
    status_code = p.wait()

    result_dict = {
        "stdout": sanitize_output(stdout) if sanitize else stdout,
        "stderr": sanitize_output(stderr) if sanitize else stderr,
        "status": status_code,
        "success": True if status_code == 0 else False,
    }

    return result_dict


def sanitize_output(text):
    # Return a stripped string without newlines
    if text:
        return text.strip().replace("\n", "").replace("\r", "")


def read_file(filename):
    """
  read_file(filename)

  Reads content of a file or returns "" if file doesn't exists
  """
    if not os.path.exists(filename):
        return ""

    with open(filename) as myfile:
        return myfile.read()


def create_parent_directory_if_necessary(filename):
    if not os.path.exists(filename):
        file_path = os.path.splitdrive(filename)[-1]
        folders = os.path.split(file_path)[0]
        try:
            os.makedirs(folders)
        except:
            pass


def write_file(filename, content=None, mode="w"):
    """
  write_file(filename, content=None, mode="w")

  Creates a file including parent directories, default mode mode is 'w'
  """
    create_parent_directory_if_necessary(filename)
    with open(filename, mode) as myfile:
        myfile.write(str(content))


def write_json_file(filename, data, mode="w", indent=2, sort_keys=True):
    """
  write_json_file(filename, data, mode='w', indent=2, sort_keys=True)

  Writes a json object to a file, creating parent directories if necessary.
  """
    assert isinstance(data, dict), "Json object type must be a dict!"
    create_parent_directory_if_necessary(filename)
    with open(filename, mode) as json_file:
        json.dump(data, json_file, indent=indent, sort_keys=sort_keys)


def get_sha1(file_path):
    """
  get_sha1(file_path)

  Returns the sha1 of the file_path
  """
    if os.path.exists(file_path):
        hash = hashlib.sha1()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), ""):
                hash.update(chunk)
            return hash.hexdigest()
    else:
        return None


def get_sha256(filename, block_size=65536):
    """
  get_sha256(file_path)

  Returns the sha256 the filename
  """
    if not os.path.exists(filename):
        return None
    sha256 = hashlib.sha256()
    with open(filename, "rb") as f:
        for block in iter(lambda: f.read(block_size), b""):
            sha256.update(block)
    return sha256.hexdigest()


def get_username():
    """
  get_username()


  Return Username
  """

    os_platform = platform.system()

    if os_platform == "Darwin":
        cmd = ["/usr/bin/stat", "-f%Su", "/dev/console"]
        default_username = run(cmd)["stdout"]

    else:
        default_username = getpass.getuser()

    username = raw_input("Username [%s]: " % default_username)
    if not username:
        username = default_username

    return username


def get_paths():
    """ Return dict of paths based on it-bin git repo path """

    repo = git.cmd.Git(os.path.dirname(__file__))
    repo_root = repo.rev_parse(show_toplevel=True)
    return {
        "repo_root": repo_root,
        "scripts": os.path.join(repo_root, "scripts"),
        "logs": os.path.join(repo_root, "scripts", "logs"),
        "shelves": os.path.join(repo_root, "shelves"),
        "dest_sync": os.path.join(repo_root, "dest_sync"),
        "git_config": os.path.join(repo_root, ".git", "config"),
        "git_exclude": os.path.join(repo_root, ".git", "info", "exclude"),
        "git_ignore": os.path.join(repo_root, ".gitignore"),
        "auth_token": os.path.join(repo_root, ".pantri_auth_token"),
    }


def get_shelf_directory(object_path):
    """
  Return the shelves directory of objects being uploaded. ie chef or mdt_images
  shelf_dir is used to determine non-default settings for uploading/syncing
  """

    shelves = get_paths()["shelves"]
    # Get relative path of object to "shelves" dir
    shelf_dir = os.path.relpath(object_path[0], shelves)
    # Split on os separator and return top directory which will be shelf name
    return shelf_dir.split(os.sep)[0]


def verify_git_repo():
    """ Verify script ran within the it-bin git repo"""

    git_remote = git.cmd.Git(get_paths()["repo_root"]).remote(verbose=True)
    # TODO add repo name
    if re.search("/repo_name", git_remote):
        return True

    return False


def get_git_commits():
    """
  get_git_commits()

  Return the pervious and current from log/refs/head/master
  """
    # Grab commits from last entry in log/refs/head/master
    repo_path = get_paths()["repo_root"]
    commits = str(git.Repo(repo_path).heads.master.log()[-1]).split()
    # Return null commit id if no commits are in the refs log
    if not commits:
        return (
            0000000000000000000000000000000000000000,
            0000000000000000000000000000000000000000,
        )
    previous_commit_id = commits[0]
    current_commit_id = commits[1]
    return previous_commit_id, current_commit_id


def changed_files():
    """
  changed_files()

  Returns (added, modified, deleted) files between git pulls.
  """
    added = []
    modified = []
    deleted = []
    repo_path = get_paths()["repo_root"]
    previous_commit_id, current_commit_id = get_git_commits()

    # Commit id of all zeros indicates repo was just cloned, therefore don't dont
    # need to check what files changed.
    if previous_commit_id == "0000000000000000000000000000000000000000":
        return (added, modified, deleted)

    # Parse diff tree to determine which files where changed between git pulls
    parts = (
        git.Git(repo_path)
        .diff_tree(
            [
                "--name-status",
                "-z",
                "--root",
                "-m",
                "-r",
                previous_commit_id,
                current_commit_id,
            ]
        )
        .split("\0")
    )

    # Loop though changes files and determine changed/added/deleted files.
    # Logic copied from fbcode.
    offset = 0
    while offset < len(parts) - 1:
        kind = parts[offset]
        path = parts[offset + 1]

        if len(kind) == 40:
            # It's a merge commit and diff-tree prints the diff between
            # both parents (separated by the commit hash). Just skip the
            # hash return a list of all the files that have changed.
            offset += 1
            continue

        offset += 2

        if kind == "M" or kind == "T":
            modified.append(path)
        elif kind == "A":
            added.append(path)
        elif kind == "D":
            deleted.append(path)
    return (added, modified, deleted)


def remove(paths):
    """
  remove(paths)

  This will remove files/directories recursively. Supports "paths" being a
  list of paths and wildcard in file names.
  Remove does nothing if path does not exist.
  """

    # recursively call remove if paths is a list
    if isinstance(paths, list):
        for file_path in paths:
            remove(file_path)
        return

    # Using glob to support wildcard in filenames
    for file_path in glob.glob(paths):
        # Only attempt to remove path if it exists
        if not os.path.exists(file_path):
            continue

        # Remove directory
        if os.path.isdir(file_path):
            try:
                shutil.rmtree(file_path)
            except:
                print("Error: %s not removed" % file_path)
            continue

        # Remove files.
        if os.path.isfile(file_path):
            try:
                os.remove(file_path)
            except:
                print("Error: %s not removed" % file_path)


def get_modified_time(file_path):
    """
  get_modified_time(file_path)

  Returns the the modified time (in seconds) of the file
  """
    if os.path.exists(file_path):
        return int(os.path.getmtime(file_path))
    return None


def get_file_size(file_path):
    """
  get_file(file_path)

  Returns file size in bytes of the file
  """
    if os.path.exists(file_path):
        return int(os.path.getsize(file_path))
    return None


def unix_path(path):
    """
  unix_path(path)

  Convert a path to use forward slash (/) instead of double backslash (\\).
  Needed when running script on windows.
  """

    return path.replace("\\", "/")


def is_binary(file_path):
    """
  is_binary(file_path)

  Uses 'file' system cmd to determine if a file is binary.
  """

    bin_regex = re.compile(r"binary")
    # Command paths per platform
    if platform.system() == "Windows":
        file_cmd = __win_find_file_exe()
    else:
        file_cmd = "/usr/bin/file"

    file_output = run([file_cmd, "--mime-encoding", "-b", file_path])["stdout"]
    if bin_regex.search(file_output) is not None:
        return True

    return False


def __win_find_file_exe():
    """
  __win_find_file_exe()

  Searches for the binary `file.exe` on Windows which is used to determine a
  file's type.
  """
    exe_path = "Git\\usr\\bin\\file.exe"
    search_paths = [
        os.path.join(os.getenv("ProgramFiles(x86)"), exe_path),
        os.path.join(os.getenv("ProgramFiles"), exe_path),
        os.path.join(os.getenv("ProgramW6432"), exe_path),
    ]
    for path in search_paths:
        if os.path.isfile(path):
            return path

    raise OSError("Git is not installed!")
