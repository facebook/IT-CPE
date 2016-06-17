#!/bin/bash 

# Skip manual check
if [ "$1" = 'manualcheck' ]; then
	echo 'Manual check: skipping'
	exit 0
fi

DIR=$(dirname $0)

mkdir -p "$DIR/cache"

DS=''
AD_COMMENTS=''

# Find which Directory Service we are bound to
DS=`/usr/bin/dscl localhost -list . | head -n 1`

echo "Directory Service = ${DS}" > "$DIR/cache/directoryservice.txt"

case "$DS" in
"Active Directory")
	# Get major OS version (uses uname -r and bash substitution)
	# osvers is 10 for 10.6, 11 for 10.7, 12 for 10.8, 13 for 10.9, etc.
	osversionlong=$(uname -r)
	osvers=${osversionlong/.*/}
	localhostname=`/usr/sbin/scutil --get LocalHostName`
	# Set variable for Domain
	domain=`dscl localhost -list /Active\ Directory`
	
	if [[ ${osvers} -ge 11 ]]; then
		AD_COMMENTS=`dscl /Search -read Computers/"${localhostname}"$ Comment 2>/dev/null | tr -d '\n' | awk '{$1 =""; print }'`
	fi
	
	if [ "${osvers}" = 10 ]; then
		AD_COMMENTS=`dscl /Active\ Directory/All\ Domains/ -read Computers/"${localhostname}"$ Comment 2>/dev/null | tr -d '\n' | awk '{$1 =""; print }'`	
	fi
	
	echo "Active Directory Comments = ${AD_COMMENTS}" >> "$DIR/cache/directoryservice.txt"
	#dsconfigad always exits with 0; trim spaces at beginning of the line and consecutive white spaces
	/usr/sbin/dsconfigad -show | grep "=" | sed 's/^[ \t]*//;s/  */ /g' >> "$DIR/cache/directoryservice.txt"
;;

"LDAPv3")
        # Get major OS version (uses uname -r and bash substitution)
        # osvers is 10 for 10.6, 11 for 10.7, 12 for 10.8, etc.
        osversionlong=$(uname -r)
        osvers=${osversionlong/.*/}
        localhostname=`/usr/sbin/scutil --get LocalHostName`
        # Set variable for Domain
        domain=`dscl localhost -list /LDAPv3`
;;

"Local") # Indicates not bound to a directory
		DS="Not bound to Directory"
		domain="Local"	
;;

*) #Default Case
		DS="Unexpected binding type"
;;
esac

echo "Active Directory Domain = ${domain}" >> "$DIR/cache/directoryservice.txt"

exit 0