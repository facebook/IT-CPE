#!/bin/bash


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
