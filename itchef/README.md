# Facebook CPE Chef cookbooks

In this directory, you can find chef cookbooks and other chef related tools.

## Quick Start
-----------
If you want to check out what the CPE suite of chef cookbooks can do:

First, download and install the chef client: https://downloads.chef.io/chef-client/
As of June 2020, the current guaranteed supported release is 15.8.23. Higher or lower
versions may work, but we haven't formally tested it.

You can either open Terminal and clone the IT-CPE repo with `git`, or you can download
the zip bundle from Github. In this example,
we'll clone it to /Users/Shared:

```
git clone https://github.com/facebook/IT-CPE /Users/Shared/IT-CPE
```

(OPTIONAL) Using your favorite text editor, open
`itchef/cookbooks/cpe_init/recipes/company_init.rb`
and find/replace `MYCOMPANY` with the name of your company.

Save and close the above file and do a local chef run in terminal:

```
cd /Users/Shared/IT-CPE/itchef
sudo chef-client -z -j quickstart.json
```

If this is your first time running Chef, you will need to accept the license agreement
when prompted by typing in `yes`.

That's it! By default, nothing should change. The Facebook API model dictates that all
cookbooks should be non-operational until told to do something.

## Tweak a few things
------------------
Lets customize a few things and see what happens.

Open `itchef/cookbooks/cpe_init/recipes/company_init.rb`
in your favorite text editor.

Add the following line to the bottom of the file:

```
# Set the screensaver idle timer
node.default['cpe_screensaver']['idleTime'] = 300

# Add a launchd that echo's nothing
node.default['cpe_launchd']['doesnothing'] = {
    'program_arguments' => ['echo', 'nothing'],
    'run_at_load' => true,
}
```

Because cpe_launchd uses the prefix set in company_init.rb, we do not need to specify a
full reverse domain name. cpe_launchd is smart enought to build the correct reverse
domain name for the LaunchDaemon.

In Terminal, cd to the `itchef` directory and do a local chef run:

```
cd /Users/Shared/IT-CPE/itchef
sudo chef-client -z -j quickstart.json
```

Check Profiles again in system preferences. You will have one more profiles with the
settings specified above. Also check `/Library/LaunchDaemons`, you should see a new one
called `com.MYCOMPANY.chef.doesnothing.plist`. (Or whatever you changed `MYCOMPANY` to.)
