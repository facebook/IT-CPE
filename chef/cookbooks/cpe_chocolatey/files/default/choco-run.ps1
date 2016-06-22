#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#
# Variables
$choco_managed_installs = (Get-Content $env:ChocolateyInstall\config\choco_req_apps.json) | ConvertFrom-Json
$local_choco_list = & choco list -localonly
$local_list = $local_choco_list[1..($local_choco_list.Count-2)]

# Create local list into an array variable
$list = @()
foreach ($line in $local_list) {
    # Split on the blank space
    $line = $line -split '\s'
    
    # Add to array
    $list += $line[0]
}


# Run chocolatey depending on the feed specified.
foreach ($app in $choco_managed_installs | Get-Member -MemberType *Property) {
    $feed = $choco_managed_installs.$($app.Name).feed
    $name = $choco_managed_installs.$($app.Name).name
    $version = $choco_managed_installs.$($app.Name).version
    
    if ($list -Contains $name) {
        & cup $name -s $feed --version $version -y
    }
    else {
        & choco install $name -s $feed --version $version -y -f
    }
}
