#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

# Prints a message into any color given below by function name.
# Examples: print_red "Install failed"
# print_green "Successful Install"

RED=$'\033[31m'
LightRED=$'\033[31;01m'

GREEN=$'\033[32m'
LightGREEN=$'\033[32;01m'

YELLOW=$'\033[1;33m'
LightYELLOW=$'\033[33;01m'

OFF=$'\033[0m'


# Print colors
function print_red () {
  # pass string you would like to print
  echo "${RED}$@${OFF}"
}


function print_lightred () {
  # pass string you would like to print
  echo "${LightRED}$@${OFF}"
}


function print_green () {
  # pass string you would like to print
  echo "${GREEN}$@${OFF}"
}


function print_lightgreen () {
  # pass string you would like to print
  echo "${LightGREEN}$@${OFF}"
}


function print_yellow () {
  # pass string you would like to print
  echo "${YELLOW}$@${OFF}"
}
