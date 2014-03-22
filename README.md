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
It would periodically lose connection to client systems causin them to become unmanaged. This meant critical patches and updates could not be sent. To solve this, we built "Launch Daemon Init (LDI)," a System Daemon that verifies the management status of the machine.
But over time LDI evolved in to a easy way to run any script or function
on a set interval (startup, daily, every15, weekly).


## Requirements
IT-CPE tools requires or works with
* Mac OS X or Linux server running SSH and rsync
* Apache server where clients can download the ssh key via rsync

## Building MyProject

* Single-purpose SSH key to your code_sync server
	We use a 'util' account that only has access to the 'code\_sync' directory.
  Reference the sites below for details on how to make a limited access SSH account.
	http://www.paulkeck.com/ssh/
	http://www.hackinglinuxexposed.com/articles/20030115.html

## Installing MyProject
...

## How MyProject works
...
* How the IT-CPE tools work

## Full documentation
...

## Join the MyProject community
* Website:
* Facebook page:
* Mailing list
* irc: irc.freenode.net / #ITThinkTank
See the CONTRIBUTING file for how to help out.

## License
MyProject is BSD-licensed. We also provide an additional patent grant.
