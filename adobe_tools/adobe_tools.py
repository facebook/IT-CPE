#!/usr/bin/python
"""Adobe API tools."""

import adobe_api


# These are the most common actions that one would use the Adobe UM API for.
def user_exists(username):
  """Return if the username exists."""
  instance = adobe_api.AdobeAPIObject(username)
  if instance.user:
    return True
  return False


def user_is_federated(username):
  """
  Return if the username exists and is federated.

  If the username does not exist, the result will be False.
  """
  instance = adobe_api.AdobeAPIObject(username)
  if instance.user and instance.is_federated():
    return True
  return False


def does_user_have_product(product, username):
  """Return True/False if a user has the specified product."""
  instance = adobe_api.AdobeAPIObject(username)
  return instance.has_product(product)


def list_user_products(username):
  """Return a list of the user's product configs."""
  instance = adobe_api.AdobeAPIObject(username)
  return instance.list_products()


def does_product_exist(productname):
  """Return True if a product config exists."""
  instance = adobe_api.AdobeAPIObject("fake@fake.com")
  return instance.product_exists(productname)


def get_product_list():
  """Return a list of product configs available."""
  instance = adobe_api.AdobeAPIObject("fake@fake.com")
  productlist = instance.gather_product_list()
  return [x['groupName'] for x in productlist]


def add_federated_user(username, email, firstname, lastname, country='US'):
  """Add federated user account."""
  instance = adobe_api.AdobeAPIObject(username)
  return instance.add_federated_user(email, country, firstname, lastname)


def remove_user(username):
  """Remove user account from organization."""
  instance = adobe_api.AdobeAPIObject(username)
  return instance.remove_user_from_org(username)


def add_products(desired_products, username):
  """Add products to specific user."""
  instance = adobe_api.AdobeAPIObject(username)
  return instance.add_products_to_user(desired_products)


def remove_products(removed_products, username):
  """Remove products from specific user."""
  instance = adobe_api.AdobeAPIObject(username)
  return instance.remove_product_from_user(removed_products)
