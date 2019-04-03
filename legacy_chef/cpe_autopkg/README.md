cpe_autopkg Cookbook
==================
This cookbook installs AutoPkg, configures the user account to use it, and adds the specified AutoPkg repositories.

Requirements
------------
* Mac OS
* cpe_remote
* cpe_utils
* mac_os_x
* git must be installed, configured, and credentials stored for GitHub (https://fburl.com/382381473, https://fburl.com/382381533)

Attributes
----------
* node['cpe_autopkg']['install']
* node['cpe_autopkg']['setup']
* node['cpe_autopkg']['update']
* node['cpe_autopkg']['user']
* node['cpe_autopkg']['dir']
* node['cpe_autopkg']['dir']['home']
* node['cpe_autopkg']['dir']['cache']
* node['cpe_autopkg']['dir']['recipeoverrides']
* node['cpe_autopkg']['dir']['recipes']
* node['cpe_autopkg']['dir']['reciperepos']
* node['cpe_autopkg']['repos']
* node['cpe_autopkg']['munki_repo']
* node['cpe_autopkg']['run_list_file']
* node['cpe_autopkg']['run_list']


Usage
------
This cookbook can be used to set up and install AutoPkg, and then manage the install of specific repos.

## Setup

If `node['cpe_autopkg']['setup']` is set to `true` on a node, then all the appropriate directories will be created if necessary, and AutoPkg will have its preferences configured to use them based on the attributes. These paths are specified by `node['cpe_autopkg']['dir']` attributes, which should be absolute paths:
* node['cpe_autopkg']['dir']['home'] # The central 'home' of AutoPkg data
* node['cpe_autopkg']['dir']['cache'] # AutoPkg Cache folder
* node['cpe_autopkg']['dir']['recipeoverrides'] # AutoPkg RecipeOverrides folder
* node['cpe_autopkg']['dir']['recipes'] # AutoPkg Recipes folder
* node['cpe_autopkg']['dir']['reciperepos'] # AutoPkg RecipeRepos folder

The cookbook will configure all of these directories to be owned by `node['cpe_autopkg']['user']`, which must be a user account present on the system.

`node['cpe_autopkg']['munki_repo']` should be a path to a Munki repo, which will be used for .munki recipe imports.

Additionally, any recipe folders added into `files/default/org_recipes/` will be copied over into the folder specified by `node['cpe_autopkg']['dir']['recipes']`. This way you can host internal-only recipes and ensure they are copied to every AutoPkg host.

## Adding Repos

Any repos you want to add to AutoPkg should be listed in `node['cpe_autopkg']['repos']`. These can be in any form accepted by the `autopkg repo-add` command (which also uses `git clone` on the backend). You can use repo names from the AutoPkg organization, or full git repo addresses:

    node.default['cpe_autopkg']['repos'] = [
      'recipes',
      'https://github.com/facebook/Recipes-for-AutoPkg.git'
    ]

## Recipe Run List

You can specify a list of recipes to be placed into a file, which will be a JSON dump of the `node['cpe_autopkg']['run_list']` array.  The path to this file is `node['cpe_autopkg']['run_list_file']`, and it will only be created if `node['cpe_autopkg']['run_list']` isn't empty.

This file can be passed directly to the `autopkg_tools.py` module.  To add recipes to the runlist:

    node.default['cpe_autopkg']['run_list_file'] =
      '/Library/CPE/var/autopkg_run_list.json'
    node.default['cpe_autopkg']['run_list'] = [
      'AdobeFlashPlayer.munki',
      'Firefox.munki',
      'GoogleChrome.munki'
    ]

You can invoke `autopkg_tools.py` with the runlist directly:

    autopkg_tools.py -s /path/to/sync-dir --list /Library/CPE/var/autopkg_run_list.json


## Example full node customization

An example configuration in a node customization:
```
node.default['cpe_autopkg']['user'] = 'nmcspadden'
node.default['cpe_autopkg']['dir']['home'] = '/Users/nmcspadden/Library/AutoPkg'
node.default['cpe_autopkg']['dir']['cache'] =
  '/Users/nmcspadden/Library/AutoPkg/Cache'
node.default['cpe_autopkg']['dir']['recipeoverrides'] =
  '/Users/nmcspadden/Library/AutoPkg/RecipeOverrides'
node.default['cpe_autopkg']['dir']['recipes'] =
  '/Users/nmcspadden/Library/AutoPkg/Recipes'
node.default['cpe_autopkg']['dir']['reciperepos'] =
  '/Users/nmcspadden/Library/AutoPkg/RecipeRepos'

node.default['cpe_autopkg']['munki_repo'] =
  '/Users/Shared/munki_repo'

node.default['cpe_autopkg']['repos'] = [
  'recipes',
  'nmcspadden-recipes',
]

node.default['cpe_autopkg']['run_list'] = [
  'AdobeFlashPlayer.munki',
  'Dropbox.munki',
]
```
