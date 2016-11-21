#!/usr/bin/python
"""Adobe API tools."""
#
# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

import sys
import time
import json
import os

try:
  import jwt
  import requests
except ImportError:
  sys.exit(0)

if sys.version_info[0] == 2:
    from ConfigParser import RawConfigParser
    from urllib import urlencode
    from urllib import quote
if sys.version_info[0] >= 3:
    from configparser import RawConfigParser
    from urllib.parse import urlencode


# INTERNAL / PRIVATE ACTIONS
def _product_list(config_data, access_token):
  """Get the list of product configurations."""
  page = 0
  result = {}
  productlist = []
  while result.get('lastPage', False) is not True:
    url = "https://" + config_data['host'] + config_data['endpoint'] + \
          "/groups/" + config_data['org_id'] + "/" + str(page)
    res = requests.get(url, headers=headers(config_data, access_token))
    if res.status_code == 200:
      # print(res.status_code)
      # print(res.headers)
      # print(res.text)
      result = json.loads(res.text)
      productlist += result.get('groups', [])
      page += 1
  return productlist


def _user_list(config_data, access_token):
  """Get a list of all users."""
  page = 0
  result = {}
  userlist = []
  while result.get('lastPage', False) is not True:
    url = "https://" + config_data['host'] + config_data['endpoint'] + \
          "/users/" + config_data['org_id'] + "/" + str(page)
    res = requests.get(url, headers=headers(config_data, access_token))
    if res.status_code == 200:
      # print(res.status_code)
      # print(res.headers)
      # print(res.text)
      result = json.loads(res.text)
      userlist += result.get('users', [])
    page += 1
  return userlist


def _users_of_product(config_data, product_config_name, access_token):
  """Get a list of users of a specific configuration."""
  page = 0
  result = {}
  userlist = []
  while result.get('lastPage', False) is not True:
    url = "https://" + config_data['host'] + config_data['endpoint'] + \
          "/users/" + config_data['org_id'] + "/" + str(page) + "/" + \
          quote(product_config_name)
    res = requests.get(url, headers=headers(config_data, access_token))
    if res.status_code == 200:
      # print(res.status_code)
      # print(res.headers)
      # print(res.text)
      result = json.loads(res.text)
      userlist += result.get('users', [])
    page += 1
  return userlist


def _add_product_to_user(config_data, products, user, access_token):
  """Add product config to user."""
  add_dict = {
    'user': user,
    'do': [
      {
        'add': {
          'product': products
        }
      }
    ]
  }
  body = json.dumps([add_dict])
  url = "https://" + config_data['host'] + config_data['endpoint'] + \
        "/action/" + config_data['org_id']
  res = requests.post(
    url,
    headers=headers(config_data, access_token),
    data=body
  )
  if res.status_code != 200:
    print(res.status_code)
    print(res.headers)
    print(res.text)
  else:
    results = json.loads(res.text)
    if results.get('notCompleted') == 1:
      print("Not completed!")
      print(results.get('errors'))
      return False
    if results.get('completed') == 1:
      print("Completed!")
      return True


def _user_data(config_data, access_token, username):
  """Get the data for a given user."""
  userlist = _user_list(config_data, access_token)
  for user in userlist:
    if user['email'] == username:
      return user
  return {}


def _products_per_user(config_data, access_token, username):
  """Return a list of products assigned to user."""
  user_info = _user_data(config_data, access_token, username)
  return user_info.get('groups', [])


def _remove_product_from_user(config_data, products, user, access_token):
  """Remove products from user."""
  add_dict = {
    'user': user,
    'do': [
      {
        'remove': {
          'product': products
        }
      }
    ]
  }
  body = json.dumps([add_dict])
  url = "https://" + config_data['host'] + config_data['endpoint'] + \
        "/action/" + config_data['org_id']
  res = requests.post(
    url,
    headers=headers(config_data, access_token),
    data=body
  )
  if res.status_code != 200:
    print(res.status_code)
    print(res.headers)
    print(res.text)
  else:
    results = json.loads(res.text)
    if results.get('notCompleted') == 1:
      print("Not completed!")
      print(results.get('errors'))
      return False
    if results.get('completed') == 1:
      print("Completed!")
      return True


def _add_federated_user(
  config_data, access_token, email, country, firstname, lastname
):
  """Add user to domain."""
  add_dict = {
    'user': email,
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
  body = json.dumps([add_dict])
  url = "https://" + config_data['host'] + config_data['endpoint'] + \
        "/action/" + config_data['org_id']
  res = requests.post(
    url,
    headers=headers(config_data, access_token),
    data=body
  )
  if res.status_code != 200:
    print(res.status_code)
    print(res.headers)
    print(res.text)
  else:
    results = json.loads(res.text)
    if results.get('notCompleted') == 1:
      print("Not completed!")
      print(results.get('errors'))
      return False
    if results.get('completed') == 1:
      print("Completed!")
      return True


def _remove_user_from_org(config_data, access_token, user):
  """Remove user from organization."""
  add_dict = {
    'user': user,
    'do': [
      {
        'removeFromOrg': {}
      }
    ]
  }
  body = json.dumps([add_dict])
  url = "https://" + config_data['host'] + config_data['endpoint'] + \
        "/action/" + config_data['org_id']
  res = requests.post(
    url,
    headers=headers(config_data, access_token),
    data=body
  )
  if res.status_code != 200:
    print(res.status_code)
    print(res.headers)
    print(res.text)
  else:
    results = json.loads(res.text)
    if results.get('notCompleted') == 1:
      print("Not completed!")
      print(results.get('errors'))
      return False
    if results.get('completed') == 1:
      print("Completed!")
      return True


# CONFIG
def get_private_key(priv_key_filename):
  """Retrieve private key from file."""
  priv_key_file = open(priv_key_filename)
  priv_key = priv_key_file.read()
  priv_key_file.close()
  return priv_key


def get_user_config(filename=None):
  """Retrieve config data from file."""
  # read configuration file
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
  return config_dict


def prepare_jwt_token(config_data, priv_key):
  """Construct the JSON Web Token for auth."""
  # set expiry time for JSON Web Token
  expiry_time = int(time.time()) + 60 * 60 * 24
  # create payload
  payload = {
    "exp": expiry_time,
    "iss": config_data['org_id'],
    "sub": config_data['tech_acct'],
    "aud": "https://" + config_data['ims_host'] + "/c/" +
           config_data['api_key'],
    "https://" + config_data['ims_host'] + "/s/" + "ent_user_sdk": True
  }
  # create JSON Web Token
  jwt_token = jwt.encode(payload, priv_key, algorithm='RS256')
  # decode bytes into string
  jwt_token = jwt_token.decode("utf-8")
  return jwt_token


def prepare_access_token(config_data, jwt_token):
  """Generate the access token."""
  # Method parameters
  url = "https://" + config_data['ims_host'] + config_data['ims_endpoint_jwt']
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
    # print response
    print(res.status_code)
    print(res.headers)
    print(res.text)
    return None


def generate_config(userconfig=None, private_key_filename=None):
  """Return tuple of necessary config data."""
  # Get userconfig data
  if userconfig:
    user_config_path = userconfig
  else:
    # user_config_path = raw_input('Path to config file: ')
    user_config_path = '/Library/Adobe/usermanagement.config'

  if not os.path.isfile(str(user_config_path)):
    print('Management config not found!')
    sys.exit(1)

  # Get private key
  if private_key_filename:
    priv_key_path = private_key_filename
  else:
    # priv_key_path = raw_input('Path to private key: ')
    priv_key_path = '/Library/Adobe/private.key'

  if not os.path.isfile(str(priv_key_path)):
    print('Private key not found!')
    sys.exit(1)

  priv_key = get_private_key(priv_key_path)
  # Get config data
  config_data = get_user_config(user_config_path)
  # Get the JWT
  jwt_token = prepare_jwt_token(config_data, priv_key)
  # Get the access token
  access_token = prepare_access_token(config_data, jwt_token)
  if not access_token:
    print("Access token failed!")
    sys.exit(1)
  return (config_data, jwt_token, access_token)


def headers(config_data, access_token):
  """Return the headers needed."""
  headers = {
    "Content-type": "application/json",
    "Accept": "application/json",
    "x-api-key": config_data['api_key'],
    "Authorization": "Bearer " + access_token
  }
  return headers


# PUBLIC FUNCTIONS
# Each of these will generate the config data it needs to work
def get_product_list():
  """Get list of products."""
  (config_data, jwt_token, access_token) = generate_config()
  productlist = _product_list(config_data, access_token)
  products = []
  for product in productlist:
    products.append(product['groupName'])
  return products


def get_user_list():
  """Get list of user emails."""
  (config_data, jwt_token, access_token) = generate_config()
  userlist = _user_list(config_data, access_token)
  names = []
  for user in userlist:
    names.append(user['email'])
  return names


def add_products(desired_products, target_user):
  """Add products to specific user."""
  (config_data, jwt_token, access_token) = generate_config()
  productlist = _product_list(config_data, access_token)
  userlist = _user_list(config_data, access_token)
  names = []
  for user in userlist:
    names.append(user['email'])
  products = []
  for product in productlist:
    products.append(product['groupName'])
  if target_user not in names:
    print("Didn't find %s in userlist" % target_user)
    return False
  for product in desired_products:
    if product not in products:
      print("Didn't find %s in product list" % product)
      return False
  result = _add_product_to_user(
    config_data,
    desired_products,
    target_user,
    access_token,
  )
  return result


def does_user_have_product(target_user, product):
  """Return True/False if a user has the specified product."""
  (config_data, jwt_token, access_token) = generate_config()
  membership = _products_per_user(config_data, access_token, target_user)
  return product in membership


def remove_products(removed_products, target_user):
  """Remove products from specific user."""
  (config_data, jwt_token, access_token) = generate_config()
  productlist = _product_list(config_data, access_token)
  userlist = _user_list(config_data, access_token)
  names = []
  for user in userlist:
    names.append(user['email'])
  products = []
  for product in productlist:
    products.append(product['groupName'])
  if target_user not in names:
    print("Didn't find %s in userlist" % target_user)
    return False
  for product in removed_products:
    if product not in products:
      print("Didn't find %s in product list" % product)
      return False
  result = _remove_product_from_user(
    config_data,
    removed_products,
    target_user,
    access_token,
  )
  return result


def add_user(email, firstname, lastname, country='US'):
  """Add federated user account."""
  (config_data, jwt_token, access_token) = generate_config()
  result = _add_federated_user(
    config_data,
    access_token,
    email,
    country,
    firstname,
    lastname,
  )
  return result


def remove_user(email):
  """Remove user account."""
  (config_data, jwt_token, access_token) = generate_config()
  result = _remove_user_from_org(
    config_data,
    access_token,
    email,
  )
  return result


def user_exists(user):
  """Does the user exist already as a federated ID?"""
  (config_data, jwt_token, access_token) = generate_config()
  result = _user_data(
    config_data,
    access_token,
    user,
  )
  if result.get('type') == 'federatedID':
    return True
  return False
