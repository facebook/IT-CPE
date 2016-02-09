#!/usr/bin/env python

# Thanks to Nick McSpadden for documenting how to do this in python:
# https://osxdominion.wordpress.com/2015/10/02/generating-pbkdf2-password-hashes-in-python-not-ruby/

import hashlib
import binascii
import os
import getpass
import random
import sys

password = getpass.getpass()

if not password:
  print("You must provide a password to hash!")
  sys.exit()
 
# b'string' for Python3 compatibility
password_literal = b'{}'.format(password)
# Get a 32 byte salt
salt = os.urandom(32)
chef_salt = binascii.hexlify(salt)

# Iterations should be at minimum 20k
base_iterations = 20000
iterations = base_iterations + random.SystemRandom().randint(5000, 40000)
 
hex = hashlib.pbkdf2_hmac('sha512', password_literal, salt, iterations, 128)
chef_password_hash = binascii.hexlify(hex)

print('-------Password Hash Info-------' + '\n')
print('Password: {}'.format(chef_password_hash))
print('Salt: {}'.format(chef_salt))
print('Iterations: {}'.format(iterations))