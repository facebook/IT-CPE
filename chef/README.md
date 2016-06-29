CPE Chef
==================
In this directory, you can find chef cookbooks and other chef related tools. 

Quick Start
-----------
If you want to check out what the CPE suite of chef cookbooks can do, it is easy to get started.

First, download and install the chef client: https://downloads.chef.io/chef-client/

Open terminal and clone the IT-CPE repo to a path of your choosing. In this example, we'll clone it to /Users/Shared

    git clone https://github.com/facebook/IT-CPE /Users/Shared/IT-CPE


Now, cd into the cookbooks directory within the repo

    cd /Users/Shared/IT-CPE/chef/cookbooks

Using your favorite text editor, open `/Users/Shared/IT-CPE/chef/cookbooks/cpe_init/recipes/company_init.rb` and find/replace `MYCOMPANY` with the name of your company. 

Save and close the above file and do a local chef run in terminal:

    cd /Users/Shared/IT-CPE/chef
    sudo chef-client -z -j quickstart.json

Thats it! If you check profiles in system preferences, you'll see that there are some profiles installed that were dynamically generated. Note that the profiles are using the name of your company in the UI.

Tweak a few things
------------------
Lets customize a few things and see what happens.

Open /Users/Shared/IT-CPE/chef/cookbooks/cpe_init/recipes/company_init.rb in your favorite text editor.

Add the following line to the bottom of the file:

    node.default['cpe_screensaver']['idleTime'] = 300
    # Ask before using flash plugin in Safari
    node.default['cpe_safari']['ManagedPlugInPolicies'] = {
      'com.macromedia.Flash Player.plugin' => {
        'PlugInFirstVisitPolicy' => 'PlugInPolicyAsk'
      }
    }
    # Add a launchd that echos nothing
    node.default['cpe_launchd']['com.MYCOMPANY.chef.CPE.doesnothing'] = {
      'program_arguments' => ['echo', 'nothing'],
      'run_at_load' => true,
    }

In terminal, cd to /Users/Shared/IT-CPE/chef/cookbooks, do a local chef run:

    cd /Users/Shared/IT-CPE/chef
    sudo chef-client -z -j quickstart.json

Check Profiles again in system preferences. You will have 2 more profiles with the settings specified above. Also check /Library/LaunchDaemons, you should see a new one called `com.MYCOMPANY.chef.CPE.doesnothing`.
