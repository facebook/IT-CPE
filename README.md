#IT-CPE tools
The IT-CPE repo is a suite of tools that we use to manage our fleet of client
machines.

## Examples
The CPE team found that we were writing alot of functions to do our day to day
work. Instead of copying and pasting needed functions to each script, we started
storing commonly used functions on our machines. But then how do we keep
these functions up-to-date? Thats when we wrote 'code\_sync'(I know, not a very
clever name).

Next we noticed that it was difficult to remember where each function was 
actually stored? So we then wrote 'autoinit'. Autoinit sources all your 
functions into each of your scripts, giving you a global namespace. 
This makes it much easier to reference any functions you have written 
previously and provides for cleaner code.

We were also noticing issues with our current client management tool. 
It would periodically lose connection to client systems so that they 
would become unmanaged. We built "Launch Daemon Init" or LDI, with 
the intention for it to verify that our managed clients were intact.
But over time LDI evolved in to a easy way to run any script or function
on a set interval. LDI is a system daemon that we wrote that runs on startup 
and on periodic intervals throughout the day.


## Requirements
IT-CPE tools requires or works with
* Mac OS X or Linux server to serve as an ssh server
<<<<<<< HEAD
* Apache server to host ssh keys as a way for clients to grab the key

## Building MyProject

* Single-purpose SSH key to your code_sync server
	We use a 'util' account that only has access to the 'code\_sync' directory.
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
* irc:
See the CONTRIBUTING file for how to help out.

## License
MyProject is BSD-licensed. We also provide an additional patent grant.
