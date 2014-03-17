#!/usr/bin/env bash


function autoinit () {

  # Created by Jonathon Elfar(https://www.facebook.com/j0n)
  #
  # Auto_init:
  #   This script is an auto initializer for IT-code codebase.
  #   Sources all of the files in the codebase except for excluded_files
  #
  # USAGE: Files using this autonit should include:
  #   [ -z $autoinit ] && { . /Library/code/lib/modules/autoinit.sh; autoinit; }

  # Ensures the user is running this in a bash shell
  if [[ -z $BASH ]]; then
    echo "You are not in a bash shell! This script was designed "\
         "for bash meaning you may encounter problems."
  fi

  # PATH GLOBALS
  code="/Library/code"
  lib="$code/lib"
  logs="$code/logs"
  modules="$lib/modules"
  scripts="$lib/scripts"
  # Sets autoinit status
  autoinit=true

  # Files to be excluded from sourcing
  excluded_files=(
    "$modules/autoinit.sh"\
  )

  source_files_in_dir "$modules"

}

#########################################################
###               Supplement Functions                 ###
#########################################################

function source_files_in_dir () {
  # Sources all bash files in a directory
  # Must pass in directory
  # Will not source files in array "excluded_files"
  # Example: source_files_in_dir "$modules"
  [ -z "$1" ] && exit

  for file in $1/*.sh; do
    !(is_in_array excluded_files "$file") && . $file
  done

}

function is_in_array () {
  # See if given string is in array
  # Must pass in array and string to search for
  # Example: is_in_array $array "foo.bar"
  # Example: is_in_array excluded_files "$modules/autoinit.sh"
  # References:
  #   http://stackoverflow.com/questions/8082947/how-to-pass-an-array-to-a-bash-function
  if [[ -z "$1" ]] || [[ -z "$2" ]]; then exit; fi

  local arr=$1[@]
  local key=$2

  for element in ${!arr}; do
    [ "$element" = "$key" ] && return 0
  done

  return 1
}

