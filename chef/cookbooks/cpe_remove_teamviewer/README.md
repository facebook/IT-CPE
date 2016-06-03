cpe_remove_teamviewer Cookbook
=====================
This cookbook completely removes Teamviewer from a Mac.


Requirements
------------
Mac OS X, with Spotlight enabled.


Usage
-----
#### cpe_remove_teamviewer::default
* Removes all Teamviewer launch agents, launch daemons, Privileged Helper tools, Security plugin bundles, and package receipts.

You can run this cookbook completely solo:
```
sudo chef-client -z --disable-config -o cpe_remove_teamviewer
```