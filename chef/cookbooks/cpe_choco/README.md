cpe_choco Cookbook
==================
Installs base applications and configures chocolatey to your environment.

Requirements
------------
`chef-client` version 1.8.1 or higher.

Attributes
----------
* node['cpe_choco']['app_cache']
* node['cpe_choco']['config']
* node['cpe_choco']['default_feed']
* node['cpe_choco']['features']
* node['cpe_choco']['installation_uri']
* node['cpe_choco']['install']
* node['cpe_choco']['uninstall']
* node['cpe_choco']['source_blacklist']
* node['cpe_choco']['sources']
* node['cpe_choco']['update_script']

Usage
-----
#### Configuration
To add a source to the chocolatey configuration, merge a hash into
`node['cpe_choco']['sources']` with the feed name as the primary key, followed
by a hash that lists the `source` and `disabled`:

    node.default['cpe_choco']['sources']['bacon'] = {
      'source' => 'http://bacon.es.yummy',
    }

This will append `bacon` to the chocolatey config and so it can be used:

    PS C:\> choco sources
    bacon - http://bacon.es.yummy | Priority 0.

To enable a feature in chocolatey, you can merge a hash into the
`node['cpe_choco']['features']` attribute of the form:

    {
      'My Awesome Feature' => { # <-- feature name
        'enabled' => true, # <-- true/false
        'setExplicitly' => true, # <-- true/false (see Notes above)
        'description' => 'Word up', # <-- a description of the feature
      }
    }

Chocolatey, of course, must actually support the features you are enabling.

Some sources might be declared to be unsafe by systems administrators. To
blacklist a source, append a string with the source's URL to the list:

    node.default['cpe_choco']['source_blacklist'] << 'http://bacon.es.yummy'

When chef converges it will go through the blacklist and remove offending
entries before rendering the template to disk:

    [2016-06-28T17:05:27-07:00] WARN: [your_recipe_name]: http://bacon.es.yummy
    is blacklisted, removing.

#### Managed Installs/Uninstalls

To make a chocolatey package part of your chef workflow append a key/value 
pair to the `node[cpe_choco]['install']` node attribute. Similarly if you want
to ensure that a particular piece of software is removed from the system you
can append a key/value pair to the `node[cpe_choco]['uninstall']` attribute.

Versions can be explicit, or to just specify whatever is latest you can supply
`latest` to that package's `version`. It is highly recommended you be explicit
about what version is deployed!

NOTE: A `version` is **REQUIRED**. If you do not specify a version the resource
will complain noisily at you and throw an exception. Versions are only passed to
the resource for installs. When a package is removed it removes any version that
is installed locally.

NOTE: If you do not specify a `source` then `choco` will use whatever is
specified in your configuration file. If you add a package that is in none of
your configured sources you will cause breakage.

Examples
--------
#### Managed Installations
To make `firefox` a required installation in your recipe just append to the
`install` attribute and ensure you specify a version with `latest`:

    node.default['cpe_choco']['install']['firefox'] = {
      'version' => 'latest'
    }

You can also optionally pass a `source`:

    node.default['cpe_choco']['install']['chocolatey'] = {
      'version' => '0.9.10.3',
      'source' => 'https://chocolatey.org/api/v2',
    }

You can remove software:

    node.default['cpe_choco']['uninstall']['teamviewer'] = {
      'version' => 'any',
    }


#### Features
In your recipe:

    node.default['cpe_choco']['features']['regretnothing'] = {
      'enabled' => true,
      'setExplicitly' => true,
      'description' => 'I REGRET NOTHING!!',
    }

#### Sources
In your recipe:

    node.default['cpe_choco']['sources']['chocolatey'] = {
      'source' => 'https://chocolatey.org/api/v2',
    }

Notes
-----
When setting up features in your chocolatey configuration be careful when using
the `setExplicitly` field. If you set it to `false` then whenever `choco.exe` is
invoked it will override your Chef settings and cause the `template` resource 
that interpolates the chocolatey configuration to behave in a non-idempotent
manner.

Contributing
------------
1. Fork this repo.
2. Add your code and write your unit tests.
3. Make sure all the unit tests pass.
4. Submit PR!
