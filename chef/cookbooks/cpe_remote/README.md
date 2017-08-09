cpe_remote cookbook
============
This cookbook has two different providers.  The first is the pkg provider (cpe_remote_pkg).  This provider is compatible with Mac and will install a package from a repo.  The second provider is a file provider (cpe_remote_file).  This provider is compatible with Mac and Windows and will download a file from a repo and place it on the client if the checksums dont match, or the file is missing on the client.

Files or pkgs must first be uploaded to our cpespace servers using Pantri. See
wiki for more details. http://fburl.com/pantri

Requirements
------------
### Platform
- Mac OS X (pkg, file providers)
- Windows (file provider only)

Resources/Providers
-------------------
### pkg

This resource will install a Osx Pkg. It will retrieve the PKG from a remote URL. The PKG file will be stored in the `Chef::Config[:file_cache_path]` and deleted after the install unless you set `cleanup` to false. If you want to install a PKG that has already been downloaded (set `remote` parameter to false), copy it to the appropriate location. You can find out what directory this is with the following command on the node to run chef:

```bash
knife exec -E 'p Chef::Config[:file_cache_path]' -c /etc/chef/client.rb
```

#### Actions
- :install - Installs the application.

#### Parameter attributes:
- `app` - This is the name of the app that the pkg will be installing.
- `checksum` - sha256 checksum of the pkg to download.
- `cleanup` - Specify whether or not we should keep the downloaded pkg.
- `pkg_name` - Specify the name of the pkg if it is not the same as `app`-`version`, or if the name has spaces.
- `receipt` - Receipt registered with pkgutil when a pkg is installed.
- `remote` - Specify whether or not we should attmpt to download the pkg.
- `version` - string of version number.

#### Examples
Install `osquery` from the primary download site.

```ruby
cpe_remote_pkg 'osqueryd' do
  version '1.1.0'
  checksum '3701fbdc8096756fab077387536535b237e010c45147ea631f7df43e3e4904e0'
  receipt 'com.facebook.osqueryd'
end
```

### file

This resource will download a file to the client from our geo load balanced cpespace servers. The file will be stored on the client at `path`.  The `folder_name` specifies the folder on the server where the file is located.  The `file_name` specifies the file within the `folder_name` to download.  The provider will only store the latest version of the file unless you set `cleanup` to false. 

#### Actions
- :create - downloads and places file on the client

#### Parameter attributes:
- `folder_name` - This is the name of the folder where the file is located on the repo
- `checksum` - sha256 checksum of the file to download. On Mac to get this use the 'shasum 256 filename' cmd.
- `cleanup` - Specify whether or not we should keep the downloaded file. (default is true)
- `file_name` - The name of the file being downloaded from the cpespace box.

#### Examples

```ruby
cpe_remote_file 'folder_name_on_cpespace_box_where_files_are_located' do
  file_name file_to_download_from_cpespace_box
  checksum the_checksum256_of_the_file
  path path_to_whitelist_on_client_system
end
```
# Install `java_white_list` from the primary download site.

```ruby
cpe_remote_file 'javaruleset' do
  file_name 'DeploymentRuleSet.jar'
  checksum '2a58674a0a3629ab623af2742ef6d2881f71240e4bd5cbd11671f74d1db86e52'
  path node['java_ruleset']['whitelist_path']
end
```
The above example will download the DeploymentRuleSet.jar file from the javaruleset folder from the chef sharepoint on our cpespace boxes. This will happen if the file is missing or the checksum on the client doesn't match Chef's checksum.

License & Authors
-----------------
- Author:: Mike Dodge (MikeDodge04@fb.com)
- Author:: Ajay Chand (achand@fb.com)

```text
Copyright 2014, Mike Dodge, Ajay Chand

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
