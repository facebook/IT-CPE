#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

"""Functions for interacting with the user in the command line"""


def prompt(detail, integer=False, max_length=None):
    """
    prompt(detail, integer=False, max_length=None)

    Prompt the user, validate and return the response
    If integer is selected, input MUST be an integer
    If max_length is specified, the input must meet the length constraints
    """
    confirm = ""
    while confirm != "y":
        if integer:
            print "Your response must be an integer!"
        if max_length:
            # Take max length arg into account if its provided
            response = raw_input("Enter %s (%s chars max): " % (
                detail, max_length)).strip()

            # If there's a max length param, make sure the response conforms.
            if len(response) > max_length:
                print "Maximum length is %s chars!" % (max_length)
            else:
                return response

        response = raw_input("Enter %s: " % (detail)).strip()
        # Check if the value is supposed to be an integer
        if integer:
            try:
                int(response)
            except (TypeError, ValueError):
                print "Input must be an integer"
                response = None

        # Make sure user actually typed something
        if response:
            print "Your response for %s: %s" % (detail, response)
            confirm = raw_input("Is that correct? [y/n]: ").lower()

    return int(response) if integer else response


def binary_prompt(prompt=None):
    """
    binary_prompt(prompt=None)

    Binary prompt (yes/no), optionally pass the prompt text
    """
    if not prompt:
        prompt = "Do you want to proceed?"
    response = ""
    responses = {"y": True, "n": False}
    while response not in responses:
        response = raw_input("%s [y/n]: " % prompt).strip().lower()
    return responses[response]
