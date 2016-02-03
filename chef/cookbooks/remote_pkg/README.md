remote_pkg cookbook
============
This cookbook has two different providers.  The first is the pkg provider (remote_pkg).  This provider is compatible with Mac and will install a package from a http server. 

Requirements
------------
### Platform
- Mac OS X

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
Install `osquery` from the primary download site. This will download a file called `osqueryd-1.1.0.pkg`.

```ruby
remote_pkg 'osqueryd' do
  version '1.1.0'
  checksum '3701fbdc8096756fab077387536535b237e010c45147ea631f7df43e3e4904e0'
  receipt 'com.facebook.osqueryd'
end
```

License & Authors
-----------------
- Author:: Mike Dodge (MikeDodge04@fb.com)
- Author:: Ajay Chand (achand@fb.com)

```text
Copyright 2016, Mike Dodge, Ajay Chand

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
