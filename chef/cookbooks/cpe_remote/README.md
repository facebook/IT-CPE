cpe_remote cookbook
============
This cookbook has two different providers - remote Apple packages (macOS only), and remote files (macOS and Windows), from web URLs.

Files or pkgs must be stored at the server you provided to base_url.

Requirements
------------
### Platform
- macOS (pkg, file providers)
- Windows (file provider only)


Attributes
----------
* node['cpe_remote']
* node['cpe_remote']['base_url']
* node['cpe_remote']['server_accessible']

Usage
-------------------
You must set `base_url`
* node['cpe_remote']['base_url']
where are your remote pkgs and files stored - "https://chang.me/chef"

* node['cpe_remote']['server_accessible']
is your server accessible? write your own check and set value to true or false. If false the resource wont fire.  

There are two providers in this cookbook. The first is the pkg provider (`cpe_remote_pkg`). This provider is compatible with macOS and will install an Apple package from a URL, unless the package receipt and version match.

The second provider is a file provider (`cpe_remote_file`). This provider is compatible with macOS and Windows, and will download a file from a URL onto the client, unless the file already exists and matches the checksum.

### pkg

This resource will install a Apple package (`.pkg` file). It will retrieve the package from a remote URL. The package file will be stored in the `Chef::Config[:file_cache_path]` and deleted after the install unless you set `cleanup` to false.

#### Actions
- :install - Install the package.

#### Parameter attributes:
- `app` - [name] This is the name of the app that the pkg will be installing,
          and the location of the pkg on the server: `base_url/app/app-version.pkg`
- `checksum` - sha256 checksum of the pkg to download.
- `cleanup` - Specify whether or not we should keep the downloaded pkg.
- `pkg_name` - Specify the name of the pkg if it is not the same as `app-version`, or if the name has spaces.
- `pkg_url` - URL of the pkg on the server if it's different than `base_url/app/app-version.pkg`.
- `receipt` - Receipt registered with pkgutil when a pkg is installed.
- `version` - string of version number.

#### Examples
Install `osquery` from the primary download site.

```ruby
# in base settings
node.default['cpe_remote']['base_url'] = "https://fb.com/chef/"
# in some recipe
# File lives at fb.com/chef/osqueryd/osqueryd-1.1.0.pkg
cpe_remote_pkg 'osqueryd' do
  version '1.1.0'
  checksum '3701fbdc8096756fab077387536535b237e010c45147ea631f7df43e3e4904e0'
  receipt 'com.facebook.osqueryd'
end
```

### file

This resource will download a file to the client from the server at `base_url`. The file will be stored on the client at `path`.  The `folder_name` specifies the folder on the server where the file is located.  The `file_name` specifies the file within the `folder_name` to download.  The provider will only store the latest version of the file unless you set `cleanup` to false.

#### Actions
- :create - download and place file on the client.

#### Parameter attributes:
- `folder_name` - [name] This is the name of the folder where the file is located on the repo.
- `checksum` - sha256 checksum of the file to download. On macOS, you can use `shasum -a 256 filename` to calculate this.
- `cleanup` - Specify whether or not we should keep the downloaded file. (default is true)
- `file_name` - The name of the file being downloaded.
- `file_url` - The url of the file being downloaded.

#### Examples

```ruby
# in base settings
node.default['cpe_remote']['base_url'] = "https://STUFF.co/chef/"
# https://STUFF.co/chef/cool_things/omgfile
# in some recipe
cpe_remote_file 'cool_things' do
  file_name 'omgfile'
  checksum the_checksum256_of_the_omgfile
  path path_of_where_to_put_file
end
```
# Install `java_white_list` from the primary download site.

```ruby
# in base settings
node.default['cpe_remote']['base_url'] = "https://STUFF.co/chef/"
# https://STUFF.co/chef/javaruleset/DeploymentRuleSet.jar
cpe_remote_file 'javaruleset' do
  file_name 'DeploymentRuleSet.jar'
  checksum '2a58674a0a3629ab623af2742ef6d2881f71240e4bd5cbd11671f74d1db86e52'
  path node['java_ruleset']['whitelist_path']
end
```
The above example will download the DeploymentRuleSet.jar file from the javaruleset folder from the server provided at `base_url`. This will only happen if the file is missing from the expected location, or the checksum on the file doesn't match the provided checksum.
