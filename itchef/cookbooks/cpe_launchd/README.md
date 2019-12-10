cpe_launchd Cookbook
====================
This is a cookbook that will manage all of the launch daemons/agents used with
chef.

Requirements
------------
macOS

Attributes
----------
* node['cpe_launchd']
* node['cpe_launchd']['prefix']

Usage
-----
Include this recipe and add any launchd items in the format shown in the
example below.

**Note:** Ensure that you override the default value of `node['cpe_launchd']['prefix']`
in a recipe (like a custom company_init). If you do not do this, it will assume
a label prefix of `com.facebook.chef`.

**THIS MUST GO IN A RECIPE. DO NOT PUT THIS IN ATTRIBUTES, OR IT MAY CAUSE PAIN
AND SUFFERING FOR YOUR FLEET!**

If you are creating a new launchd, in your recipe add a key to
node.default['cpe_launchd'] that is the name of the label of the launchd that
you would like to create and the value should be the key found in the launchd
docs on docs.chef.org

```
node.default['cpe_launchd']['com.facebook.chef.CPE.chefctl'] = {
  'program_arguments' => ['/opt/scripts/chef/chefctl.sh'],
  'run_at_load' => true,
  'start_interval' => 1800,
  'time_out' => 600
}
```

To make the launchd service definition conditional, add the optional 'only_if'
attribute, and set it to a proc that will be evaluated by the resource at
runtime:

```
node.default['cpe_launchd']['com.facebook.chef.CPE.chefctl'] = {
  'only_if' => proc { boolean_expression },
  ...
}
```

If you are porting a daemon over from the old way of managing services you can
used to old label name and we will take care of pre-pending com.facebook.chef,
and delete the old daemon for you. Also this shows how to add a key to a set of
launch daemons

```
script = '/Library/scripts/launch_daemon_init.sh'
{
  'com.CPE.daily' => {
    'program_arguments' => [ script, 'daily' ],
    'start_calendar_interval' => { 'Hour' => 10 },
  },
  'com.CPE.every15' => {
    'program_arguments' => [ script, 'every15' ],
    'start_interval' => 900,
  },
  'com.CPE.hourly' => {
    'program_arguments' => [ script, 'hourly' ],
    'start_interval' => 3600,
  },
  'com.CPE.startup' => {
    'program_arguments' => [ script, 'startup' ],
    'run_at_load' => true,
  }
}.each do |k, v|
  node.default['cpe_launchd'][k] = v
  node.default['cpe_launchd'][k]['time_out'] = 14400
end
```
