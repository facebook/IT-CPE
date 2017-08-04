# IT-CPE tools
The IT-CPE ("Client Platform Engineering") repo contains a suite of tools that we use to manage our fleet of over 10,000 client
machines.

## Presentations
* Watch our [presentation at MacIT](http://www.youtube.com/watch?v=Z3gMXUxI0Hs)
* Watch our [presentation at MacADUK](https://www.youtube.com/watch?v=VIzgMavUFRQ)


#### Code sync
We are constantly developing functions to make our scripts more robust. Both functions and scripts are deployed to all client machines via 'code sync' to ensure the latest code is always running.

#### Autoinit
A common problem that our team ran into was sourcing functions in multiple
libraries. In order to increase developer efficiency and code readability, we create 'autoinit' to automatically source functions into the script and introduce a global namespace.

#### Launch Daemon Init (LDI)
We also noticed issues with our previous client management tool. Periodically, client machines would lose connection with the mangement tools and become unmanaged.
Critical patches and updates were unable to be sent to the client. To solve this, we built "Launch Daemon Init (LDI)," a system daemon that runs scripts and functions on set intervals (startup, daily, every15, weekly).

#### _tools.py
While the bash functions greatly increased our productivity, we realized that bash made using more advanced data types and error handling difficult. Python has enabled use to write more robust scripts and handle errors/edge cases more easily. The modules folder contain abstractions we've built to make things such as validating network states easy.

#### Pyexec
Similiar to autoinit for bash, we wanted a solution to automatically import our custom modules. Pyexec handles the necessary path modifications so you can focus more time on writing powerful scripts.

#### AutoPkg Runner
This is an [AutoPkg](https://github.com/autopkg/autopkg/) wrapper script that makes use of git to handle importing items into Munki git repo. It creates a separate git feature branch and puts up a commit for each item that is imported, to help automate controlled flow of new packages into Munki.
See the internal README for more information.

## Requirements
* (code sync server) server running ssh and rsync. Responds to 'code sync' requests 
* (key server) server running apache/nginx to host the rsync key - can be on the code sync server 
* A fleet of Mac machines to manage
* _tools.py requirements, download the modules below and move them into the /modules directory:
  * Envoy - github.com/kennethreitz/envoy
  * Requests - github.com/kennethreitz/requests

## Installing IT-CPE tools repo
* Set the hostnames of your code sync and key server in the code_sync.sh file. These values will be used by all clients when they sync the code library

* Generate a key scan of your code sync server to establish trust between clients and the code sync server via `ssh-keyscan -t rsa yourcodesyncserver.com`. Place the resulting fingerprint into your /etc/ssh_known_hosts file on all your client machines. A sample file is placed at IT-CPE/code/lib/conf/ssh_known_hosts.

* The key server should run apache/nginx to servere the contents of the single-use SSH key. Clients will download the rsync key from this server using a curl. Clients will use this key to rsync code from the code sync server to the client.

* Setup the code sync server. Setup a limited access SSH account, such as a 'util' account that only has access to the code sync directory. See the links below for more details on creating a limited access SSH account.
 * http://www.paulkeck.com/ssh/
 * http://www.hackinglinuxexposed.com/articles/20030115.html

* Update global variables in the modules in /modules to those that best fit your environment. For example, check_corp.sh requires a "CORP_URL" variable to be set to an internal url specific to your environment.

* Setup your code base on the code sync server. Copy the contents of the /conf, /modules and /scripts folders over to your code sync server in a shared folder served by apache/nginx. The clients will rsync against the shared folder for the latest codebase.

  
## Repo layout
* /conf. Configuration files, e.g. ssh_known_hosts that contains the fingerprint of the code sync server.
* /modules. Python and bash modules/functions designed to be re-used in your scripts.
* /scripts. Scripts to be stored/executed on client machines.
* /SSH_server. Contains a ssh validation script to verify clients will be able to download the codebase.
* /autopkg. Contains AutoPkg recipes.


## Help and Support
Find us on IRC on irc.freenode.net / #ITThinkTank if there are questions or issues.

## Join the IT-CPE community
* [Facebook IT Website](https://fb.com/it)
* [Facebook group] (https://fb.com/groups/TheITThinkTank)
* irc: irc.freenode.net / #ITThinkTank

## License
IT-CPE tools is BSD-licensed. We also provide an additional patent grant.
