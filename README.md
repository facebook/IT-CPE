#IT-CPE tools
The IT-CPE repo is a a suite of tools that we use to manage our fleet of client
systems.

## Examples
We found that we were writing alot of fuctions to do our day to day
work, instead of copying pasting needed functions to each script we started
storeing commonly used functions on our moachines. But then how do you keep
these functions uptodate? Thats when we wrote 'code\_sync'(I know, not a very
clever name).

Next we noticed that it was alot of work to rmeber which function is stored
were? So with 'autoinit' it sources all the functions, that you have written,
so you can set constants and fuctions, in one place, and have them all ready for
you to use.

We were also noticing that with our current client management system, it would
lose connection or systems would just become unmanaged. We bulit 'Lanuch Demon
init' with the intention for it to just veirfy that our mangement client was
intact. But over time it evolved in to a easy way to run any script or function
on a set interval.


## Requirements
IT-CPE tools requires or works with
* Mac OS X or Linux server to serve as an ssh server
* Apache server to sevre ssh key or way to deploy the key to each machine

## Building MyProject

* Single-purpose SSH key to your code_sync server
	I use a 'util' account that only as access to the 'code\_sync' directory.
	http://www.paulkeck.com/ssh/
	http://www.hackinglinuxexposed.com/articles/20030115.html

## Installing MyProject
...

## How MyProject works
...

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
