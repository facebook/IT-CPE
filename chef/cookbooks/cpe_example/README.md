cpe_example Cookbook
=====================
Provides an example cookbook to use as a template.

Requirements
------------
* some OS

Attributes
----------
* node['cpe_example']['configure']

* node['cpe_example']['pkg']['version']
* node['cpe_example']['pkg']['checksum']
* node['cpe_example']['pkg']['name']

* node['cpe_example']['log_locations']

Usage
-----
This recipe is an EXAMPLE for how to structure an API cookbook. You can use this
as a template to create a new API cookbook by simply copying it with `hg cp`:

```
hg cp cookbooks/core/cpe_example cookbooks/core/cpe_my_cookbook_name
```

Once copied, you can fill in all the blanks with your code and replace all the
names with your own, and write all of your own code.

You'll also want to provide a good ReadMe, so here's what some sample readme
content will look like:

### Example ReadMe

* configure
  true -> things get done
  false -> do not install/enable something

* pkg dictionary describing what package to install
  * version
    version of the package to install
  * checksum
    SHA256 checksum of the package to install
  * name
    name of the package to install
