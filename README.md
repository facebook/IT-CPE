#IT-CPE tools
The IT-CPE repo contains a suite of tools that we use to manage our fleet of client
machines.  We currently manage over 10k machines using this tools.

## Examples
The CPE team found that we were writing alot of functions to do our day to day
work. Instead of copying and pasting needed functions to each script, we started
storing commonly used functions on our machines. But then how do we keep
these functions up-to-date? Thats when we wrote 'code\_sync'(I know, not a very
clever name). Apple does not always provide the best tools for the enterprise. The CPE team constantly wrote functions and scripts to achieve a variety of different tasks. These scripts execute locally on the client machines. To utilize the code library, we needed a mechanism to deploy the code library to client machines. The CPE team embodies the Facebook mantra, "Move Fast and Break Things." We continually iterate and improve the code library. We needed a mechanism to keep up with our rapid development cycle, to solve the problem we wrote 'code_sync'.

Next we noticed that it was difficult to remember where each function was 
actually stored? So we then wrote 'autoinit'. Autoinit sources all your 
functions into each of your scripts, giving you a global namespace. 
This makes it much easier to reference any functions you have written 
previously and provides for cleaner code. Bash is not forgiving when sourcing a multitude of functions. It requires the memorization of function paths. This became tedious, introduced unnecessary errors, and stalled the development process not allowing us to "move fast." To remove the headaches of development and following "the hacker way" of iteration, we wrote 'autoinit' to automatically source the code library's functions and provide a global namespace. Not only does this make development straightforward, the readability of code has greatly improved.

We were also noticing issues with our current client management tool. 
It would periodically lose connection to client systems causin them to become unmanaged. This meant critical patches and updates could not be sent. To solve this, we built "Launch Daemon Init (LDI)," a System Daemon that verifies the management status of the machine. But over time LDI evolved in to a easy way to run any script or function on a set interval (startup, daily, every15, weekly).


## Requirements
IT-CPE tools requires:
* Mac OS X or Linux server running SSH and rsync. This server stores the code base for clients to rsync down. We will call this the code sync server.
* Linux Apache server hosting the ssh rsync key.  We will call this the key server.
* A fleet of Mac machines to manage

## Installing IT-CPE tools repo

* Set the hostnames of your code sync and key server in the code_sync.sh file
These values will be used by all clients when they sync the code library

* Generate an keyscan of your code sync server
  To do this from a terminal type: ssh -t rsa yourcodesyncserver.com.  Place the resulting fingerprint into your /etc/ssh_known_hosts file on all your client machines.  This establishes the trust to the code sync server. A sample file is placed at IT-CPE/code/lib/conf/ssh_known_hosts.

* Setup the key server
  This server should be running Apache and should serve the contents of the single-use SSH key.  Clients will download the rsync key from this server using a curl.  Once downloaded, they will use this key for access to do the rsync from the code sync server to grab the latest version of the code base.

* Setup the codesync server
  Setup a limited access SSH account. We call this account a 'util' account that only has access to the 'code\_sync' directory.
  Reference the sites below for details on how to make a limited access SSH account.

* Configure global variables for your environment
  Under each script in the /modules folder, assign variables that fit your enviroment where required by the code.  For example, check_corp.sh requires a "CORP_URL" variable to be set for your environment.

* Setup your code base on the codesync server
  Copy the contents of the /conf, /modules and /scripts folder over to your codesync server in a shared folder.  This is the folder that clients will rsync from to grab the latest version of the codebase.

  http://www.paulkeck.com/ssh/
  http://www.hackinglinuxexposed.com/articles/20030115.html


## Repo layout
* /conf.  Contains configuration files.  ssh_known_hosts is a file that shows how to grab the fingerprint of your code sync server.
* /modules.  Contains a variety of functions that are useful for clients to have.  Each function should have a detailed description within the file contents.
* /scripts.  Contain scripts that we want the clients to execute. 
* /SSH_server. Contains a script that runs on the SSH Server that verifies that the client SSH command is to download the contents of the code sync library. #MIKE#


## Help and Support
Find us on IRC on irc.freenode.net / #ITThinkTank if there are questions or issues.

## Join the MyProject community
* Website:
* Facebook page:
* Mailing list
* irc: irc.freenode.net / #ITThinkTank
See the CONTRIBUTING file for how to help out.

## License
MyProject is BSD-licensed. We also provide an additional patent grant.
