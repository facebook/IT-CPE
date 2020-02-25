#!/usr/bin/python
# Copyright (c) Facebook, Inc. and its affiliates.
"""Module to interact with the Adobe User Management API."""

from __future__ import print_function
import json
import os
import platform
import random
import sys
import time

try:
    import jwt
    import requests
except ImportError:
    print("Missing 'jwt' and/or 'requests' modules.")
    exit(1)

if sys.version_info[0] == 2:
        from ConfigParser import RawConfigParser
        from urllib import urlencode
        from urllib import quote
elif sys.version_info[0] >= 3:
        from configparser import RawConfigParser
        from urllib.parse import urlencode


# Constants for fallback
USERCONFIG_DEFAULT_LOC = '/Library/Adobe/usermanagement.config'
PRIVATE_KEY_DEFAULT_LOC = '/Library/Adobe/private.key'
CACHE_DEFAULT_LOC = '/Library/Adobe/adobe_tools.json'


# User lookup functions
def get_console_user():
    """Find out who is logged in right now."""
    current_os = platform.system()
    if 'Darwin' in current_os:
        # macOS: Use SystemConfiguration framework to get the current
        # console user
        from SystemConfiguration import SCDynamicStoreCopyConsoleUser
        cfuser = SCDynamicStoreCopyConsoleUser(None, None, None)
        return cfuser[0]
    if 'Windows' in current_os:
        from win32api import GetUserName
        return GetUserName()
    if 'Linux' in current_os:
        from getpass import getuser
        return getuser()


# Exception classes used by this module.
class AdobeAPINoUserException(Exception):
    """Given user does not exist."""

    def __init__(self, username):
        """Store the user that doesn't exist."""
        self.username = username

    def __str__(self):
        """String for the username."""
        return "No user found for '%s' " % str(self.username)


class AdobeAPINoProductException(Exception):
    """Given product does not exist."""

    def __init__(self, product):
        """Store the product that doesn't exist."""
        self.product = product

    def __str__(self):
        """String for the product."""
        return "No product configuration for '%s'" % str(self.product)


class AdobeAPIBadStatusException(Exception):
    """Received a non-200 code from the API."""

    def __init__(self, status_code, headers, text):
        """Store the product that doesn't exist."""
        self.status_code = status_code
        self.headers = headers
        self.text = text

    def __str__(self):
        """Text for the error."""
        return 'Status code %s: %s' % (self.status_code, str(self.text))

    def __int__(self):
        """Return status code of the error."""
        return int(self.status_code)


class AdobeAPIIncompleteUserActionException(Exception):
    """User manipulation action returned an incomplete."""

    def __init__(self, errors):
        """Store the error generated from the incomplete."""
        self.errors = errors

    def __str__(self):
        """Text for the error."""
        return str(self.errors)


class AdobeAPIMissingRequirementsException(Exception):
    """Missing a required file for API usage."""

    def __init__(self, filename):
        """Store the filename that is missing."""
        self.filename = filename

    def __str__(self):
        """Text for the error."""
        return 'Required file is missing: %s' % str(self.filename)


class AdobeAPIObject(object):
    """Model to represent an Adobe API interface."""

    def __init__(
        self,
        username="%s@fb.com" % get_console_user(),
        private_key_filename=PRIVATE_KEY_DEFAULT_LOC,
        userconfig=USERCONFIG_DEFAULT_LOC,
        cache_path=CACHE_DEFAULT_LOC,
        cache=True,
        key='email',
        allow_nonexistent_user=False,
        splay=random.randrange(-144, 144),
    ):
        """
        Instantiate class variables for our API object model.

        'username' defaults to the current logged in user on all platforms.

        'private_key_filename', 'userconfig', and 'cache_path' will default to
        the constants defined above if not provided.

        'cache' defaults to True to consume available cache data, and to store
        the data in local cache. False will not cache and ignores any local
        cache file.
        The cache path is defined in the constant above.

        'key' must be either 'email' or 'username', and determines what field
        to match the incoming data off of. By default, this is the 'email'
        field.

        'allow_nonexistent_user' will not trigger an exception if you try to
        perform an action on a user that does not exist. This is useful for
        determining if a user exists, or querying lists of product configs,
        where you don't actually need to interact with a user to do so.

        'splay' is a number of hours added to the cache length. By default,
        this is a random value between -144 and 144 hours, so that machines
        don't all invalidate their cache and query the API endpoint at the
        same time.

        This can be confusing because regardless of key choice, 'username' is
        used to indicate the unique user.
        """
        self.configs = {}
        self.productlist = []
        self.userlist = []
        self.cache_path = cache_path
        self.user = {}
        self.username = username
        self.cache = cache
        self.key = key
        self.allow_fake = allow_nonexistent_user
        self.splay = splay
        if self.cache:
            self.__read_cache()
        # Generate the access configs in case we need them later
        self.__generate_config(
            userconfig=userconfig,
            private_key_filename=private_key_filename
        )
        if not self.user:
            # Cache didn't have values we need, so let's query the API
            self.gather_user()
        if not self.productlist:
            self.gather_product_list(force=True)
        if self.cache:
            self.__write_cache()

    # CONFIG
    def __get_private_key(self, priv_key_filename):
        """Retrieve private key from file."""
        priv_key_file = open(priv_key_filename)
        priv_key = priv_key_file.read()
        priv_key_file.close()
        return priv_key

    def __get_user_config(self, filename=None):
        """Retrieve config data from file."""
        config = RawConfigParser()
        config.read(filename)
        config_dict = {
            # server parameters
            'host': config.get("server", "host"),
            'endpoint': config.get("server", "endpoint"),
            'ims_host': config.get("server", "ims_host"),
            'ims_endpoint_jwt': config.get("server", "ims_endpoint_jwt"),
            # enterprise parameters used to construct JWT
            'domain': config.get("enterprise", "domain"),
            'org_id': config.get("enterprise", "org_id"),
            'api_key': config.get("enterprise", "api_key"),
            'client_secret': config.get("enterprise", "client_secret"),
            'tech_acct': config.get("enterprise", "tech_acct"),
            'priv_key_filename': config.get("enterprise", "priv_key_filename"),
        }
        self.configs = config_dict

    def __prepare_jwt_token(self):
        """Construct the JSON Web Token for auth."""
        # set expiry time for JSON Web Token
        expiry_time = int(time.time()) + 60 * 60 * 24
        # create payload
        payload = {
            "exp": expiry_time,
            "iss": self.configs['org_id'],
            "sub": self.configs['tech_acct'],
            "aud": (
                "https://" +
                self.configs['ims_host'] +
                "/c/" +
                self.configs['api_key']
            ),
            (
                "https://" +
                self.configs['ims_host'] +
                "/s/" +
                "ent_user_sdk"
            ): True
        }
        # create JSON Web Token
        jwt_token = jwt.encode(payload, self.priv_key, algorithm='RS256')
        # decode bytes into string
        jwt_token = jwt_token.decode("utf-8")
        return jwt_token

    def __prepare_access_token(self, config_data, jwt_token):
        """Generate the access token."""
        # Method parameters
        url = "https://" + config_data['ims_host'] + \
            config_data['ims_endpoint_jwt']
        headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Cache-Control": "no-cache"
        }
        body_credentials = {
            "client_id": config_data['api_key'],
            "client_secret": config_data['client_secret'],
            "jwt_token": jwt_token
        }
        body = urlencode(body_credentials)
        # send http request
        res = requests.post(url, headers=headers, data=body)
        # evaluate response
        if res.status_code == 200:
            # extract token
            access_token = json.loads(res.text)["access_token"]
            return access_token
        else:
            raise AdobeAPIBadStatusException(
                res.status_code, res.headers, res.text
            )

    def __generate_config(self, userconfig, private_key_filename):
        """Return tuple of necessary config data."""
        # Get userconfig data
        user_config_path = userconfig
        if not os.path.isfile(str(user_config_path)):
            raise AdobeAPIMissingRequirementsException(str(user_config_path))

        # Get private key
        priv_key_path = private_key_filename
        if not os.path.isfile(str(priv_key_path)):
            raise AdobeAPIMissingRequirementsException(str(priv_key_path))

        self.priv_key = self.__get_private_key(priv_key_path)
        # Get config data
        self.__get_user_config(user_config_path)
        # Get the JWT
        try:
            self.jwt_token = self.__prepare_jwt_token()
        except NotImplementedError:
            print(
                "Cryptography module was unable to succeed on your machine.",
                file=sys.stderr)
            raise
        # Get the access token
        self.access_token = self.__prepare_access_token(
            self.configs,
            self.jwt_token
        )

    def __headers(self, config_data, access_token):
        """Return the headers needed."""
        headers = {
            "Content-type": "application/json",
            "Accept": "application/json",
            "x-api-key": config_data['api_key'],
            "Authorization": "Bearer " + access_token
        }
        return headers

    # REQUEST INTERACTION FUNCTIONS
    def __submit_request(self, url):
        """
        Submit a request to the API endpoint.

        Returns a JSON dictionary of the result.
        If a non-200 status is returned, raise an AdobeAPIBadStatusException.
        """
        res = requests.get(
            url,
            headers=self.__headers(self.configs, self.access_token)
        )
        if res.status_code != 200:
            raise AdobeAPIBadStatusException(
                res.status_code,
                res.headers,
                res.text
            )
        return json.loads(res.text)

    def _submit_user_action_request(self, body_dict):
        """
        Submit a JSON request to the User Action API.

        Returns True if the action succeeded.
        If the action was not completed, raise
        AdobeAPIIncompleteUserActionException.
        """
        success = False
        body = json.dumps([body_dict])
        url = "https://" + self.configs['host'] + \
              self.configs['endpoint'] + "/action/" + \
              self.configs['org_id']
        res = requests.post(
            url,
            headers=self.__headers(self.configs, self.access_token),
            data=body
        )
        if res.status_code != 200:
            raise AdobeAPIBadStatusException(
                res.status_code,
                res.headers,
                res.text
            )
        results = json.loads(res.text)
        if results.get('notCompleted') == 1:
            raise AdobeAPIIncompleteUserActionException(
                results.get('errors')
            )
        if results.get('completed') == 1:
            success = True
        self.update_user()
        return success

    # CACHE FUNCTIONS
    def __read_cache(self):
        """Read the values from the cache file."""
        cache_data = {}
        try:
            # Invalidate the cache automatically after 2 weeks, plus splay
            file_age = os.path.getmtime(self.cache_path)
            # Splay is a number of hours added to the cache invalidation time
            # It can be negative, so that clients don't all hit at once.
            splay_seconds = 60 * 60 * int(self.splay)
            two_weeks = (60 * 60 * 24 * 14)
            if time.time() - file_age < (two_weeks + splay_seconds):
                with open(self.cache_path, 'rb') as f:
                    cache_data = json.load(f)
        except (OSError, IOError, ValueError):
            # Cache doesn't exist, or is invalid
            self.user = {}
            return
        productlist = cache_data.get('productlist', [])
        if productlist:
            self.productlist = productlist
        userlist = cache_data.get('userlist', [])
        if userlist:
            self.userlist = userlist
        user_data = cache_data.get('user_data', {})
        if user_data and user_data.get(self.key) == self.username:
            self.user = user_data
        else:
            # Look through the userlist to see if we find the username.
            # If not, the result is an empty dict anyway.
            self.user = self.data()

    def __write_cache(self):
        """Write the values to the cache file."""
        cache_data = {}
        cache_data['productlist'] = self.productlist or []
        cache_data['userlist'] = self.userlist or []
        cache_data['user_data'] = self.user or {}
        try:
            with open(self.cache_path, 'wb') as f:
                json.dump(cache_data, f, indent=True, sort_keys=True)
        except IOError:
            # If we fail to write cache, it just means we check again next time
            pass

    # GATHERING DATA FROM THE API
    # These functions all must query the API (directly or indirectly) for info
    # not available from the cache, and are therefore expensive.
    def gather_product_list(self, force=False):
        """
        Get the list of product configurations by asking the API.

        Returns 'productlist', which is a list of dictionaries containing all
        the Configuration groups in use.
        If 'force' is true, the API call will be made regardless of cache.
        If a non-200 status code is returned by the API, an exception is
        raised.

        Example:
        ```
        >>>> api.productlist[0]
        {u'memberCount': 182, u'groupName': u'Administrators'}
        >>> api.productlist[1]
        {u'memberCount': 912,
        u'groupName':
            u'Default Document Cloud for enterprise - Pro Configuration'}
        ```
        """
        if force or not self.productlist:
            page = 0
            result = {}
            productlist = []
            while result.get('lastPage', False) is not True:
                url = "https://" + self.configs['host'] + \
                    self.configs['endpoint'] + "/groups/" + \
                    self.configs['org_id'] + "/" + str(page)
                try:
                    result = self.__submit_request(url)
                    productlist += result.get('groups', [])
                    page += 1
                except AdobeAPIBadStatusException:
                    raise
            self.productlist = productlist
        # Update the cache
        if self.cache:
            self.__write_cache()
        return self.productlist

    def gather_user_list(self, force=False):
        """
        Get a list of all users by querying the API.

        Returns 'userlist', which is a list of dictionaries containing all the
        users in our org.
        If 'force' is true, the API call will be made regardless of cache.
        If a non-200 status code is returned by the API, an exception is
        raised.

        Example:
        ```
        >>> api.userlist[0]
        {u'status':
            u'active', u'username': u'email@fb.com', u'domain': u'fb.com',
        u'firstname': u'Fake Firstname', u'lastname': u'Fake Lastname',
        u'groups': [
            u'Default Document Cloud for enterprise - Pro Configuration',
            u'Default All Apps plan - 100 GB Configuration',
            u'Default Illustrator CC - 0 GB Configuration',
            u'Default InDesign CC - 0 GB Configuration',
            u'Default Photoshop CC - 0 GB Configuration'],
        u'country': u'US', u'type': u'federatedID', u'email': u'email@fb.com'}
        """
        if force or not self.userlist:
            page = 0
            result = {}
            userlist = []
            while result.get('lastPage', False) is not True:
                url = "https://" + self.configs['host'] + \
                    self.configs['endpoint'] + "/users/" + \
                    self.configs['org_id'] + "/" + str(page)
                try:
                    result = self.__submit_request(url)
                    userlist += result.get('users', [])
                    page += 1
                except AdobeAPIBadStatusException:
                    raise
            self.userlist = userlist
        # Update the cache
        if self.cache:
            self.__write_cache()
        return self.userlist

    def users_of_product(self, product_config_name):
        """
        Get a list of users of a specific configuration by querying the API.

        'userlist' is a list of dictionaries containing the user data of each
        user who is a member of that product configuration group.
        If a non-200 status code is returned by the API, an exception is
        raised.

        Example:
        ```
        >>> api.users_of_product(
            'Default Document Cloud for enterprise - Pro Configuration')[0]
        {u'status': u'active', u'username': u'email@fb.com',
        u'domain': u'fb.com', u'firstname': u'Fake', u'lastname': u'Fake',
        u'country': u'US', u'type': u'federatedID', u'email': u'email@fb.com'}
        ```

        This data is not cached, so it is an expensive call each time.
        """
        page = 0
        result = {}
        userlist = []
        while result.get('lastPage', False) is not True:
            url = "https://" + self.configs['host'] + \
                self.configs['endpoint'] + "/users/" + \
                self.configs['org_id'] + "/" + str(page) + "/" + \
                quote(product_config_name)
            try:
                result = self.__submit_request(url)
                userlist += result.get('users', [])
                page += 1
            except AdobeAPIBadStatusException as e:
                error = json.loads(e.text)
                if 'group.not_found' in error['result']:
                    # Invalid product name
                    raise AdobeAPINoProductException(product_config_name)
                else:
                    raise
        return userlist

    def data(self):
        """Get the data for the user from the userlist."""
        for user in self.userlist:
            if user[self.key] == self.username:
                return user
        # If we get here, there was no matching username
        return {}

    def gather_user(self):
        """
        Gather data about the user by querying the API.

        Returns a dictionary containing the user data.
        If a non-200 status code is returned by the API, an exception is
        raised.

        This data is cached, but this function does not read from the cache;
        it will always fetch from the API.

        If the user does not exist and 'allow_nonexistent_user' was not set to
        True, this raises an AdobeAPINoUserException.
        """
        url = "https://" + self.configs['host'] + \
            self.configs['endpoint'] + "/organizations/" + \
            self.configs['org_id'] + "/users/" + str(self.username)
        try:
            result = self.__submit_request(url)
            self.user = result.get('user', {})
        except AdobeAPIBadStatusException:
            if self.allow_fake:
                self.user = {}
                return
            raise AdobeAPINoUserException(self.username)

    # USER SPECIFIC FUNCTIONS
    # These convenience functions are all based on the user that the object was
    # instantiated with.
    def list_products(self):
        """Return the list of products for the current user."""
        return self.user.get('groups', [])

    def is_federated(self):
        """Return True if user is federated."""
        return self.user.get('type') == 'federatedID'

    def has_product(self, product_name):
        """Return True if user has the product config."""
        return product_name in self.list_products()

    def update_user(self):
        """Force update the user information."""
        # Rebuild the userlist for updated information
        self.gather_user()
        if self.cache:
            self.__write_cache()

    # PRODUCT SPECIFIC FUNCTIONS
    # These are not at all related to the user, and do not require a real user.
    def product_exists(self, productname):
        """Return True if a product config exists."""
        if not self.productlist:
            self.gather_product_list()
        for product in self.productlist:
            if productname == product.get('groupName', ''):
                return True
        return False

    # ACTION FUNCTIONS
    # These functions are actions you can take on the user, which require
    # posting data to the API.
    def add_federated_user(self, email, country, firstname, lastname):
        """Add Federated user to organization."""
        add_dict = {
            'user': self.username,
            'do': [
                {
                    'createFederatedID': {
                        'email': email,
                        'country': country,
                        'firstname': firstname,
                        'lastname': lastname,
                    }
                }
            ]
        }
        result = self._submit_user_action_request(add_dict)
        return result

    def update_user_information(self, email, country, firstname, lastname):
        """Update the existing user's information."""
        add_dict = {
            'user': self.username,
            'do': [
                {
                    'update': {
                    }
                }
            ]
        }
        if email:
            add_dict['do'][0]['update']['email'] = email
        if country:
            add_dict['do'][0]['update']['country'] = country
        if firstname:
            add_dict['do'][0]['update']['firstname'] = firstname
        if lastname:
            add_dict['do'][0]['update']['lastname'] = lastname
        result = self._submit_user_action_request(add_dict)
        return result

    def remove_user_from_org(self):
        """Remove user from organization."""
        if not self.user:
            raise AdobeAPINoUserException(self.username)
        remove_dict = {
            'user': self.username,
            'do': [
                {
                    'removeFromOrg': {}
                }
            ]
        }
        result = self._submit_user_action_request(remove_dict)
        return result

    def add_products_to_user(self, products):
        """Add product configs to username."""
        # Is username in the organization?
        if not self.user:
            raise AdobeAPINoUserException(self.username)
        # Is the product real?
        if isinstance(products, basestring):  # NOQA
            products = [products]
        for product in products:
            if not self.product_exists(product):
                raise AdobeAPINoProductException(product)
        add_dict = {
            'user': self.username,
            'do': [
                {
                    'add': {
                        'product': products
                    }
                }
            ]
        }
        return self._submit_user_action_request(add_dict)

    def remove_product_from_user(self, products):
        """Remove products from username."""
        # Is username in the organization?
        if not self.user:
            raise AdobeAPINoUserException(self.username)
        if isinstance(products, basestring):  # NOQA
            products = [products]
        # Is the product real?
        for product in products:
            if not self.product_exists(product):
                raise AdobeAPINoProductException(product)
        add_dict = {
            'user': self.username,
            'do': [
                {
                    'remove': {
                        'product': products
                    }
                }
            ]
        }
        return self._submit_user_action_request(add_dict)
# END CLASS
