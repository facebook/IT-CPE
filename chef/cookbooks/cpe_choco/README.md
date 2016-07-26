`cpe_choco` Cookbook
=============================
Installs base apps through chocolatey and configures chocolatey to your
environment.


Requirements
------------
This community cookbook:

[windows](https://github.com/chef-cookbooks/windows)


Notes
----
When setting up features in your chocolatey configuration be careful when using
the `setExplicitly` field. If set it to `false` then whenever `choco.exe` is
invoked it will override your settings and cause the `template` resource that
interpolates the configuration to behave in a non-idempotent manner.


Usage
------------
To add a source to the chocolatey configuration, merge a hash into
`node['cpe_choco']['sources']` with the feed name as the primary key, followed
by a hash that lists the `source` and `disabled`:
```
node.default['cpe_choco']['sources']['bacon'] =
  'source' => 'http://bacon.es.yummy',
}
```

This will append `bacon` to the chocolatey config and so it can be used:
```
PS C:\> choco sources
bacon - http://bacon.es.yummy | Priority 0.
```

To enable a feature in chocolatey, you can merge a hash into the
`node['cpe_choco']['features']` attribute of the form:
```
{
  'My Awesome Feature' => { # <-- feature name
    'enabled' => true, # <-- true/false
    'setExplicitly' => true, # <-- true/false (see Notes above)
    'description' => 'Word up', # <-- a description of the feature
  }
}
```

Examples:
```
node.default['cpe_choco']['features']['nooOp'] = {
  'enabled' => false,
  'setExplicitly' => true,
  'description' => 'I do not do a thing!',
}
node.default['cpe_choco']['features']['regretnothing'] = {
  'enabled' => true,
  'setExplicitly' => true,
  'description' => 'I REGRET NOTHING!!',
}
```

```
PS C:\> choco features
...
nooOp - [Disabled] | I do not do a thing!
regretnothing - [Enabled] | I REGRET NOTHING!!
```

Chocolatey, of course, must actually support the features you are enabling.

Some sources might be declared to be unsafe by systems administrators. To
blacklist a source, append a string with the source's URL to the list:
```
node.default['cpe_choco']['source_blacklist'] << 'http://bacon.es.yummy'
```
When chef converges it will go through the blacklist and remove offending
entries before rendering the template to disk:
```
[2016-06-28T17:05:27-07:00] WARN: [your_recipe_name]: http://bacon.es.yummy is
blacklisted, removing.
```


Contributing
------------
1. Make sure the unit tests pass.
2. Add new tests for new features.
3. Submit PR!
