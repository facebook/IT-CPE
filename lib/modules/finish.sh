#!/bin/bash


function finish () {
  #Cleanup the files that were created

  #This is the clean up
  rm $logs/$current_file_name 1> /dev/null 2>&1
  return 0
}
