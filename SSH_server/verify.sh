#!/bin/bash

# /*
# * Copyright (c) 2015-present, Facebook, Inc.
# * All rights reserved.
# *
# * This source code is licensed under the BSD-style license found in the
# * LICENSE file in the root directory of this source tree. An additional grant 
# * of patent rights can be found in the PATENTS file in the same directory.
# */

if [ "$SSH_ORIGINAL_COMMAND" = "rsync --server --sender -vlogDtpr . /code/lib" ]; then
  $SSH_ORIGINAL_COMMAND
  exit
fi

# Exiting, Command passed didnt match allowed
echo '**************'>&2
echo "$SSH_ORIGINAL_COMMAND" >&2
echo '*Unauthorized* (/[^o^])*/(-_-)' >&2
echo '**************'>&2
exit 1
