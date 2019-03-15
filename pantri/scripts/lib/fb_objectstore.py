#  Copyright (c) Facebook, Inc. and its affiliates. All rights reserved.

import os
import json
import getpass
import platform
import sys

# Third party modules
import swiftclient
import swiftclient.service

import config
import utils
import logger


class FB_ObjectStore(object):
  """
  Class for dealing with SwiftStack Object Store.
  """

  def __init__(self, options):
    """
    __init__(self):

    Instantiate class variables
    """

    # TODO reseach decorators for logging and configs
    if not options:
      options = config.get_options('default', {})
    self.options = options
    self.logger = logger.get_logger()
    self.paths = utils.get_paths()
    self.git_path = self.paths['repo_root']

  # TODO learn more about this fucntions and add logic on enter to create
  # connection to object store.
  # Magic functions to use with statements
  def __enter__(self):
    self.auth_token = self.get_auth_token()
    return self

  def __exit__(self, exc_type, exc_val, exc_tb):
    return self

  def get_file_creds(self):
    password_file = os.path.join(self.git_path,  '.pantri_password')
    if os.path.exists(password_file):
      try:
        creds = json.loads(utils.read_file(password_file))
        return creds
      except ValueError:
        self.logger.error('Unable to parse password file.')
        sys.exit(1)
    else:
        raise IOError(
          'Cannot find .pantri_password. Unable to proceed.')

  def prompt_for_creds(self):
    if 'password_file' in self.options.keys():
        return False

    return True


  def get_auth_creds(self):
    """
    return username, password to request auth token. If method is 'retrieve'
    and -p/--password_file arg is passed, user cred from .pantri_password.
    Else prompt user for creds
    """

    # Handling non-interactive actions.
    prompt_for_creds = self.prompt_for_creds()

    if prompt_for_creds:
      self.logger.info('Enter Credentials to Pull Auth Token')
      username = utils.get_username()
      password = getpass.getpass()
      return username, password
    else:
      creds = self.get_file_creds()
      return creds['username'], creds['password']

  def get_cached_auth_token(self):
    """ Return auth_token cached in .pantri_auth_token """

    # Return cached auth token.
    auth_token_cache = os.path.join(self.git_path,  '.pantri_auth_token')
    if os.path.exists(auth_token_cache):
      try:
        auth_token = json.loads(utils.read_file(auth_token_cache))['auth_token']
        return auth_token
      except:
        pass

    return None

  def validate_auth_token(self, auth_token):
    """ Validate auth_token by listing container. """
    try:
      # Exception will be thrown if auth token is invalid
      swiftclient.client.head_container(
        url=self.options['storage_url'],
        token=auth_token,
        container=self.options['object_store_container'],
      )
      return True
    except:
      self.logger.debug('Auth token is invalid.')
      return False

  def request_auth_token(self):
    """ Using username & password, request auth_token from Swift """
    # Get username/password
    username, password = self.get_auth_creds()
    try:
      storage_url, auth_token = swiftclient.client.get_auth(
        self.options['auth_url'],
        username,
        password
      )
      return auth_token
    except Exception as error:
      self.logger.debug('request_auth_token error: %s' % error)
      self.logger.error('Failed to get auth token. Try again')
      sys.exit(1)

  def cache_auth_token(self, auth_token):
    """ cache auth_token to .pantri_auth_token """
    # Cache auth token
    auth_token_cache = os.path.join(self.git_path,  '.pantri_auth_token')
    utils.write_json_file(auth_token_cache, {'auth_token': auth_token})
    self.logger.info('Auth token stored in %s' % auth_token_cache)

  def get_auth_token(self):
    """  Return auth token either from cache or request from object store """

    auth_token_cache = os.path.join(self.git_path,  '.pantri_auth_token')

    # only use cached token if method is 'store' and 'password_file' arg is not
    # passed
    use_cached_auth_token = (
      self.options['method'] == 'store' or not
      'password_file' in self.options.keys()
    )
    if os.path.exists(auth_token_cache) and use_cached_auth_token:
      auth_token = self.get_cached_auth_token()
      # Validate and return cached auth token.
      if auth_token and self.validate_auth_token(auth_token):
        return auth_token
      else:
        self.logger.info('Auth token is invalid. Requesting a new token...')

    auth_token = self.request_auth_token()
    if use_cached_auth_token:
      self.cache_auth_token(auth_token)

    return auth_token

  def parse_response(self, response):
    """
    parse_response(self, response)

    Parses response to determine if action was seccessful and logs messages to
    stdout.
    """

    # Try/Except will catch wrong response values. ie, empty dict or string
    try:
      # Exclude 'create_container' failures since current setup doesnt give
      # users rights to create container. Not an issue unless container
      # doesnt exist
      if response['action'] == 'create_container':
        self.logger.debug('SKIP: (action: create_container)')
        return False

      if response['success']:
        success_msg = 'SUCCESS'
        action = response['action']
        if (
          action == 'upload_object' and
          response['status'] == 'skipped-changed'
        ):
          action = response['status']
          success_msg = 'NOTHING'
        message = '%s (action: %s) Object: %s' % (
          success_msg,
          action,
          response['object'],
        )
        self.logger.info(message)
        return True

      if not response['success']:
        message = ' FAILURE (action: %s) Object: %s Traceback: %s' % (
          response['action'],
          response['object'],
          response['traceback'],
        )
        self.logger.warn(message)
        return False
    except:
      self.logger.warn('FAILURE: Unknown response from Swift')
      return False

  def upload(self, objects_to_upload):
    """
    upload(self, objects)

    Uploads list of objects to object store. Unchanged files (filesize &
    modified time) are skipped. Relaies on swiftclient.service.SwiftService
    class to do a majority of the work to upload objects.
    """

    objects = []
    for obj in objects_to_upload:
      objects.append(
        swiftclient.service.SwiftUploadObject(
          source=os.path.join(self.paths['shelves'], obj),
          object_name=obj
        )
      )

    # Create connection to object store and upload objects
    with swiftclient.service.SwiftService(
      options={
        'os_storage_url': self.options['storage_url'],
        'os_auth_token': self.auth_token
      }
    ) as swift:
      # need for loop to read all responses returned. ie generators
      for response in swift.upload(
        container=self.options['object_store_container'],
        objects=objects,
        options={
          'changed': True,
          'segment_size': 4294967296,
          'use_slo': True,
          'segment_container': 'segments',
        }
      ):
        # Yield successful uploads
        if self.parse_response(response):
          yield response['object']

  def delete_untested(self, objects_to_delete):
    """
    delete(self, objects_to_delete)

    Deletes objects from object store. Not meant to be used until tested more.
    """

    # Create connection to object store and delete objects
    with swiftclient.service.SwiftService(
      options={
        'os_storage_url': self.options['storage_url'],
        'os_auth_token': self.auth_token
      }
    ) as swift:
      for response in swift.delete(
        container=self.options['object_store_container'],
        objects=objects_to_delete,
      ):
        self.parse_response(response)

  def download(self, objects_to_sync):
    """
    download(self, objects_to_sync)

    Downloads list of objects from object store
    """

    objects = []
    for obj in objects_to_sync:
      objects.append(obj)

    # Create connection to object store and download objects
    with swiftclient.service.SwiftService(
      options={
        'os_storage_url': self.options['storage_url'],
        'os_auth_token': self.auth_token
      }
    ) as swift:
      for response in swift.download(
        container=self.options['object_store_container'],
        objects=objects,
        options={'out_directory': self.options['dest_sync']}
      ):
        self.parse_response(response)
