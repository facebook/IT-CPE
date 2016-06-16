#  Copyright (c) 2015-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

"""Functions that abstract filesystem interaction"""

import distutils
import glob
import filecmp
import os
import shutil
import tempfile

import shell_tools
import sys_tools

try:
    import cPickle as pickle
except:
    import pickle


def copy(target, destination):
    """
    copy(target_file, destination)

    Copies from target to destination
    """

    if os.path.isdir:
        distutils.dir_util.copy_tree(target, destination)
    else:
        shutil.copy(target, destination)


def create_file(filename):
    """
    create_file(filename)

    Creates an empty file, similiar to the touch command
    """
    write_file(filename)


def diff_replace(dst_file, src_file, verbose=False, mode=0644, backup=True):
    """
    diff_replace(dst_file, src_file, mode=0644, backup=True, verbose=False)

    Updates a dst_file with a file from given path if the files differ.
    Makes a backup of the original file (by default) by appending .fs_tools.bak
    to the file extension. Local file permissions are changed to 644(by default)
    """
    assert os.path.exists(src_file), \
        "Error: %s does not exist" % src_file

    # Only compare src_file and dst_file if dst_file exists
    if os.path.exists(dst_file) and filecmp.cmp(dst_file, src_file):
        if verbose:
            print "%s and %s are the same" % (dst_file, src_file)
        return

    # Make a backup copy of the local file if backup=True and dst_file exists
    dst_file_bak = dst_file + '.fs_tools.bak'
    if backup and os.path.exists(dst_file):
        copy(dst_file, dst_file_bak)
        if verbose:
            print "Backed up %s to %s" % (dst_file, dst_file_bak)

    copy(src_file, dst_file)

    # Update permissions on the file
    os.chmod(dst_file, mode)
    if verbose:
        print "%s and %s differ" % (dst_file, src_file)
        print "Successfully copied %s -> %s" % (src_file, dst_file)
        print "Successfully changed permissions on %s" % (dst_file)


def get_creation_time(file_path):
    """
    get_creation_time(file_path)

    Returns the the creation time (in seconds) of the file
    """
    return int(os.path.getmtime(file_path))


def get_pickle(pickle_name, pickle_path='/var'):
    """
    get_pickle(pickle_name, pickle_path='/var'):

    This returns the value of the pickle_name from pickle_path
    """
    return pickle.load(open("%s/%s" % (pickle_path, pickle_name), "rb"))


def move(original_path, new_path):
    """
    move(original_path, new_path)

    Moves the original_path to new_path
    """
    try:
        shutil.move(original_path, new_path)
    except Exception:
        raise


def mkdir(path):
    """
    mkdir(path)

    Creates the directory including parent directories
    """
    try:
        os.makedirs(path)
    except OSError:
        pass


def mktempdir(mode=None):
    """
    mktempdir(mode=None)

    Creates a temp directory with default permissions of 600
    """
    dir_name = tempfile.mkdtemp()
    if mode:
        os.chmod(dir_name, mode)


def read_file(filename):
    """
    read_file(filename)

    Returns the content from the filename
    """
    with open(filename) as myfile:
        return myfile.read()


def remove(remove_path):
    """
    remove(remove_path)

    This will remove a file/directory recursively and supports wildcard in
    file names. Remove assumes the remove_path is valid and file/path removal
    is successful, otherwise an assertion error will be thrown.
    """
    try:
        if os.path.isdir(remove_path):
            shutil.rmtree(remove_path)
        else:
            for fileName in glob.glob(remove_path):
                os.remove(fileName)
    except Exception:
        raise


def timestamp_file(path):
    """
    timestamp_file(path)

    Creates a file containing the time in UNIX (epoch) time
    """
    write_file(path, shell_tools.get_unix_time())


def write_file(filename, content=None, mode="w"):
    """
    write_file(filename, content=None, mode="w")

    Creates a file including parent directories, default mode mode is 'w'
    """
    if not os.path.exists(filename):
        file_path = os.path.splitdrive(filename)[-1]
        folders = os.path.split(file_path)[0]
        mkdir(folders)
    with open(filename, mode) as myfile:
        myfile.write(str(content))


def write_pickle(pickle_object, pickle_name, pickle_path='/var'):
    """
    write_pickle(pickle_object, pickle_name, pickle_path='/var')

    Uses pickle to write the pickle_object to the pickle_name,
    the value can be read from get_pickle
    """
    try:
        mkdir(pickle_path)
        pickle.dump(
            pickle_object, open("%s/%s" % (pickle_path, pickle_name), "wb"))
    except:
        sys_tools.log(
            "fs_tools-error", "Unable to write %s pickle" % pickle_name)
        pass


def verify_pickle(pickle_name, cache_expiration, pickle_path='/var'):
    """
    def verify_pickle(pickle_path, cache_expiration)

    Validate that the file exists, contains data, and is within the cache time
    range
    """
    pickle_path = "%s/%s" % (pickle_path, pickle_name)
    if os.path.exists(pickle_path):
        if os.stat(pickle_path).st_size > 0:
            if (get_creation_time(pickle_path) + cache_expiration) > shell_tools.get_unix_time():
                return True
        remove(pickle_path)
    return False
