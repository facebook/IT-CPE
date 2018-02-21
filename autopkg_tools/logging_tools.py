#!/usr/bin/env python2

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

from tempfile import NamedTemporaryFile
import logging
import os
import platform
import re
import sys
import time
import traceback


import cpe.pyexec.core.shell_tools as shell_tools


class LoggerContext(object):
    """A context manager to track execution of code throughout multiple
        scripts.

    By wrapping a function in a context manager, we can track execution time,
    traceback messages, exit codes, and how it was executed. This can be
    sent to an external logger.

    To use, pass a function in to main():

        def test():
            pass
        with LoggerContext() as context:
            context.main(test, command_name="my_test")

    Attributes:
        _do_exit (bool): Invoke sys.exit() upon completion of the function
            passed to LoggerContext.main().
        _latency_start (int): UNIX timestamp of start of execution.
        _debug_log (str): Path to debug log file.
        command_name (str): Name of command that was invoked.
        command_argv (list): List of strings of arguments passed to command.
        latency (int): Total seconds taken to run
            LoggerContext.main().
        exit_code (int): Exit code of LoggerContext.main().
        exception_text (str): Exception text of thrown exception from
            LoggerContext.main().
        verbose_log_url (str): EverPaste URL of debug log.
        unix_user (str): Unix name of user invoking command.
    """

    __slots__ = (
        '_do_exit',
        '_latency_start',
        '_debug_log',
        'command_name',
        'command_argv',
        'latency',
        'exit_code',
        'exception_text',
        'verbose_log_url',
        'unix_user',
    )

    def __init__(self):
        self._do_exit = False  # bool
        self._latency_start = None  # float
        self._debug_log = None
        self.command_name = None
        self.command_argv = None
        self.latency = None  # int
        self.exit_code = None  # int
        self.exception_text = None
        self.verbose_log_url = None
        self.unix_user = None

    def main(self, runner_func, command_name=None):
        self._do_exit = True
        self.command_name = command_name or sys.argv[0]
        self.command_argv = ' '.join(sys.argv)
        self.exit_code = runner_func(self)

    def __enter__(self):
        self._latency_start = time.time()
        return self

    def __exit__(self, exc_type, exc_value, tb):
        if exc_value is not None:
            self.exit_code = 1
            self.exception_text = traceback.format_exc()
        logging.info(
            traceback.format_exception_only(exc_type, exc_value)[-1].strip()
        )
        self.latency = int(time.time() - self._latency_start)
        self.log()
        if self._do_exit:
            sys.exit(self.exit_code)
        return True

    def log(self):
        # Send to an intern logger
        # Replace this with your own 'get current user' function
        user = "testuser"
        self.unix_user = user
        if self.exit_code != 0 and self._debug_log is not None:
            self.verbose_log_url = convert_log_to_url(self._debug_log)
        context_dict = {
            s: getattr(self, s, None) for s in self.__slots__ if
            not s.startswith("_")
        }
        context_dict['host_name'] = get_hostname()
        # send this to your log system
        # log_to_logger(LOGGER_CONFIG, context_dict)
        # return for testability
        return context_dict


def setup_logging(log_fname_prefix, loglevel, context):
    """
    Set up logging for common usage.

    This logger prints out stream content to sys.stdout formatted like this:
        2017-11-27 20:23:13  INFO: Message
    If the level is set to anything less than ERROR, a debug log file is also
    created, and all content (logging.DEBUG and up) is sent there as well.

    To use, create a Logger Context and pass it in to the logging setup:

        context_manager = logging_tools.LoggerContext()
        base_log_level = logging.INFO
        logging_tools.setup_logging(
            "name of command", base_log_level, context_manager)

    Args:
        log_fname_prefix (str): prefix for temp file name for debug log.
        loglevel (int): default level for output. Anything below this level is
            not shown. A value below ERROR creates a debug log file.
        context: a LoggerContext object to pass data outside execution.
    """

    mylogger = logging.getLogger()
    mylogger.setLevel(logging.DEBUG)
    setup_stream_handler(mylogger, loglevel)

    if loglevel < logging.ERROR:
        log_file = NamedTemporaryFile(prefix=log_fname_prefix + '.',
                                      suffix='.log', delete=False)
        file_handler = logging.FileHandler(log_file.name)
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(logging.Formatter(
            fmt='%(asctime)s  %(message)s', datefmt='%Y-%m-%d %H:%M:%S'))
        mylogger.addHandler(file_handler)
        logging.info("Writing verbose debug log to: " + log_file.name)
        context._debug_log = log_file.name
    return mylogger


def setup_stream_handler(logger, loglevel):
    """Remove old stream handler and add a new one."""
    stream_handler = logging.StreamHandler(sys.stdout)  # defaults to stderr
    stream_handler.setLevel(loglevel)
    stream_handler.setFormatter(logging.Formatter(
        fmt='%(asctime)s  %(levelname)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S')
    )
    logger.addHandler(stream_handler)


def log_to_cpe_logger(message, msg_type, action, status, stdout=True):
    """Log to the CPE logger at CPE_LOGGER_PATH."""
    root_logger = logging.getLogger()
    mylogger = logging.getLogger("cpe_logger")
    mylogger.setLevel(logging.INFO)
    our_formatter = logging.Formatter(
        fmt='%(asctime)s; %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S %z'
    )
    # Set up file handler
    log_file = CPE_LOGGER_PATH
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(our_formatter)
    mylogger.addHandler(file_handler)
    if stdout:
        # Now the stream handler to stdout
        stream_handler = logging.StreamHandler(sys.stdout)
        stream_handler.setLevel(logging.INFO)
        stream_handler.setFormatter(our_formatter)
        mylogger.addHandler(stream_handler)
        root_logger.disabled = True
    # Message must always match a certain structure
    msg = 'type: {}; action: {}; status: {}; msg: {};'.format(
        msg_type, action, status, message
    )
    mylogger.info(msg)
    root_logger.disabled = False


def everpaste(content, permanent=False):
    pass


def convert_log_to_url(log_path):
    """Convert a log path to a URL."""
    verbose_url = None
    if log_path is not None and os.path.isfile(log_path):
        with open(log_path, 'rb') as f:
            try:
                content = f.read()
                verbose_url = everpaste(content)
            except Exception as e:
                logging.warning(
                    'Unable to send log to paste: {}'.format(e)
                )
    return verbose_url


def run_main(command_name, main):
    with LoggerContext() as context:
        context.main(main, command_name=command_name)


def get_hostname(clean=True):
    """Get the machine's hostname."""
    current_os = platform.system()
    if 'Darwin' in current_os:
        from SystemConfiguration import SCDynamicStoreCopyComputerName
        hostname = SCDynamicStoreCopyComputerName(None, None)[0]
    elif 'Linux' in current_os:
        hostname = ''
        if os.path.isfile('/etc/hostname'):
            try:
                with open('/etc/hostname', 'r') as f:
                    hostname = f.read().strip()
                    hostname = hostname.split('.')[0]  # Force the short name
            except Exception:
                pass
        if hostname == '':
            hostname = shell_tools.run_deprecated("hostname")["stdout"]
    else:
        raise NotImplementedError(
            "get_hostname() is not available for {0}".format(sys.platform)
        )
    # Remove special_characters from hostname.
    if clean:
        # Add regex excape charaters to special_characters.
        special_characters = re.escape(""" !@#$%^&*'"+=[]{}()\/|,?<>:;~`""")
        # Replace special_characters.
        hostname = re.sub('[%s]' % special_characters, '', hostname)
    return hostname
