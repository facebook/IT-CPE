cpe_utils Cookbook
==================
This cookbook is where we keep all the common function / classes

Usage
-----
* node.app_installed?
  Returns a boolean value stating whether or osquery detects that a given
  application (defined by the application's name) is installed.

  ```
  if node.app_installed?('com.apple.Pages')
    do_thing
  else
    do_other_thing
  end
  ```

* node.installed?
  Same concept as `node.app_installed?`, but only available for macOS (leverages
  `app_paths_deprecated` and, subsequently, `app_paths_deprecated`); application
  is defined by the application's bundle identifier (_not_ app name, as is the
  case with `app_installed`).

  ```
  if node.installed?('firefox')
    do_thing
  else
    do_other_thing
  end
  ```

* node.app_paths
  Cross-platform function utilizing osquery to return the path(s) to an
  installation of a given application.

  ```
  node.app_paths('firefox').each do |app_path|
    "Firefox installation located at #{app_path}"
  end
  ```

* node.app_paths_deprecated
  Same concept as `node.app_paths`, but only available for macOS (leverages
  `mdfind`; Spotlight)

  ```
  node.app_paths_deprecated('firefox').each do |app_path|
    "Firefox installation located at #{app_path}"
  end
  ```

* node.mac_bundleid_installed?
  Returns a boolean evaluation, via osquery, for the existence of a provided bundle
  identifier.

  ```
  if node.mac_bundleid_installed?('com.apple.Pages')
    node.munki_installed?('Pages')
  end
  ```

* node.loginwindow?
  Returns `true` if the device is sitting at the login window.

  ```
  osx_profile 'Install some user profile' do
    only_if { !node.loginwindow? }
    profile 'com.company.someuserprofile.mobileconfig'
  end
  ```

* node.macos_mdm_state
  Returns either `nil` (not enrolled in MDM) or a string value denoting the state
  of MDM on the device (i.e. `mdm`, `uamdm`, or `dep`).

  ```
  if node.macos_mdm_state.nil?
    include_recipe 'cpe_umad::default'
  else
    Chef::Log.debug("#{node.macos_mdm_state}")
  end
  ```

* node.dep?
  Returns `true` if the device is enrolled into MDM via DEP.

  ```
  if node.dep? do
    something
  end
  ```

* node.uamdm?
  Returns `true` if the device is enrolled into MDM with user-approval.

  ```
  if node.uamdm? do
    something
  end
  ```

* node.mdm?
  Returns `true` if the device is enrolled into MDM (via any methodology).

  ```
  if node.mdm? do
    something
  end
  ```

* node.windows_supports_long_paths?
  Returns `true` when Windows build is greater than `10.0.14393` and, therefore,
  supports long paths.

  ```
  if node.windows_supports_long_paths?
    do_thing
  else
    do_other_thing
  end
  ```

* node.sysnative_path
  Returns a string value containing the proper path to the `System32` directory.

  ```
  if node.windows?
    Dir["#{node.sysnative_path}*"].each do |system32_item|
      system32_item
    end
  end
  ```

* node.uuid
  Returns a string of the device's UUID (as determined by `system_profiler`'s
  `SPHardwareDataType`).

  ```
  "UUID has changed!" if node.uuid != node['first_run']['attributes']['uuid']
  ```

* node.warn_to_remove
  Appends a warning entry to Chef log if the node function dictates that sharding
  cleanup is needed.

  ```
  warn_to_remove(3) if Time.now.tv_sec > Time.parse(start_time).tv_sec + 100
  ```

* node.serial
  Returns a string of the macOS device's serial number (as determined by `ioreg`).

  ```
  if node.serial.start_with?('RM')
    node['refurbished'] == true
  else
    node['refurbished'] == false
  end
  ```

* node.console_user
  Returns a string value of the user with a current console session, and memoizes
  the value for performance of recurrent use.

  ```
  launchd 'com.company.internaltool.launchagent' do
    label 'com.company.internaltool.launchagent'
    run_at_load true
    type 'agent'
    action :enable
    only_if { node.console_user != 'root' }
  end
  ```

* node.loginctl_users
  On Linux, returns a hash of currently logged in user (format:
  `{ 'uid' => Integer(uid), 'username' => uname }`).

  ```
  if node.loginctl_users['username'] == 'root'
    "Current console session is root"
  else
    "Current console session is not root"
  end
  ```

* node.attr_lookup
  Allows you to dig through the node's attributes but still get back an arbitrary
  value in the event the key does not exist.

  ```
  if node.attr_lookup('ohai/some_custom_plugin/some_custom_plugin_attribute')
    do_thing
  else
    do_other_thing
  end
  ```

* node.in_shard?
  Evaluates whether or not a node is within (read: less-than or equal-to) a passed
  sharding threshold.

  ```
  remote_pkg 'ChefDK' do
    only_if { node.in_shard?(50) }
    version '3.11.3-1'
    checksum '7dfc54c290a0f5d889a50dbe292eb5b862e99ed6826fae5882ed29a93c2c5a17'
    receipt 'com.getchef.pkg.chefdk'
  end
  ```

* node.get_shard
  Using the device's serial (preferred for Darwin/Linux) or `system_uuid`
  (preferred for Windows), calculate and return an integer representing the shard
  (1-100) in which the node exists.

  ```
  if node.get_shard == 42
    'This is a bad example'
  end
  ```

* node.os_greater_than?
  If the current system's OS X version is greater than the specified version, do
  something.

  ```
  if node.os_greater_than?('10.10') do
    something
  end
  ```

* node.os_less_than?
  If the current system's macOS version is less than the specified version, do
  something.

  ```
  if node.os_less_than?('10.11') do
    something
  end
  ```

* node.os_at_least?
  This functions like a greater than or equal to. In this example, if the machine
  is 10.11.1 or greater, it will run something.

  ```
  if node.os_at_least?('10.11.1') do
    something
  end
  ```

* node.os_at_least_or_lower?
  This functions like a less than or equal to. In this example, if the machine
  is 10.10.3 or lower, it will run something.

  ```
  if node.os_at_least_or_lower?('10.10.3') do
    something
  end
  ```

* OS Checks
  These are to check if a node is a specific OS family, type, or version.

  ```
  node.arch_family?
  node.debian_family?
  node.fedora_family?
  node.arch?
  node.centos?
  node.debian?
  node.debian_sid?
  node.fedora?
  node.fedora27?
  node.fedora28?
  node.linux?
  node.linuxmint?
  node.macosx?
  node.macos?
  node.ubuntu?
  node.ubuntu14?
  node.ubuntu15?
  node.ubuntu16?
  node.ubuntu18?
  node.windows?
  node.windows8?
  node.windows8_1?
  node.windows10?
  node.windows2012?
  node.windows2012r2?
  ```

  These are generally used to scope OS-specific features. For instance:

  ```
  if node.macos?
    osx_profile 'com.company.screensaver.mobileconfig'
  end
  ```

  These can also be used within a resource block via only_if

  ```
  osx_profile 'Install screensaver profile' do
    only_if { node.macos? }
    profile 'com.company.screensaver.mobileconfig'
  end
  ```

* node.virtual_macos_type
  Determines whether the node is a virtualized instance of macOS and, if so, returns
  a string value of the virtualization providers employed (`vmware`, `virtualbox`,
  `parallels`). If the node is not virtualized, `physical` will be returned.

  ```
  remote_pkg 'VMWareTools' do
    only_if { node.virtual_macos_type == 'vmware' }
    version '1.1.0'
    checksum '3701fbdc8096756fab077387536535b237e010c45147ea631f7df43e3e4904e0'
    receipt 'com.vmware.tools'
  end
  ```

* node.virtual?
  This is similar to the OS check functions, except it checks to see if the
  machine is a virtual machine (guest). This is useful for scoping things like
  VMWare Tools installs to VMs only.

  ```
  remote_pkg 'VMWareTools' do
    only_if { node.virtual? }
    version '1.1.0'
    checksum '3701fbdc8096756fab077387536535b237e010c45147ea631f7df43e3e4904e0'
    receipt 'com.vmware.tools'
  end
  ```

* node.parallels?
  This is similar to node.virtual?, except it will allow you to apply granular
  conditions based on virtual machine type. This is useful for scoping tools to
  specific virtualization platforms.

  ```
  remote_pkg 'parallels_tools'
    only_if { node.parallels? }
    source 'https://someserver/sometool.pkg'
  end
  ```

* node.vmware?
  This is similar to node.virtual?, except it will allow you to apply granular
  conditions based on virtual machine type. This is useful for scoping tools to
  specific virtualization platforms.

  ```
  remote_pkg 'vmware_tools'
    only_if { node.vmware? }
    source 'https://someserver/sometool.pkg'
  end
  ```

* node.virtualbox?
  This is similar to node.virtual?, except it will allow you to apply granular
  conditions based on virtual machine type. This is useful for scoping tools to
  specific virtualization platforms.

  ```
  remote_pkg 'virtualbox_tools'
    only_if { node.virtualbox? }
    source 'https://someserver/sometool.pkg'
  end
  ```

* node.min_package_installed?
  This allows you to wrap a conditional item, based on the package receipt version.
  This checks to see if the minimum receipt version is present.

  ```
  launchd 'com.googlecode.munki.app_usage_monitor' do
    keep_alive true
    label 'com.googlecode.munki.app_usage_monitor'
    program_arguments ['/usr/local/munki/app_usage_monitor']
    run_at_load true
    type 'agent'
    action :enable
    only_if do
      node.min_package_installed?('com.googlecode.munki.app_usage', '3.3.0.3513')
    end
  end
  ```

* node.max_package_installed?
  This allows you to wrap a conditional item, based on the package receipt version.
  This checks to see if the maximum receipt version is present.

  ```
  launchd 'com.googlecode.munki.app_usage_monitor' do
    keep_alive true
    label 'com.googlecode.munki.app_usage_monitor'
    program_arguments ['/usr/local/munki/app_usage_monitor']
    run_at_load true
    type 'daemon'
    action :enable
    only_if do
      node.max_package_installed?('com.googlecode.munki.app_usage', '3.2.1.3498')
    end
  end
  ```

* node.munki_installed?
  Returns true if the item is in munki's managed_installs list.

  ```
  if node.munki_installed?('Firefox') do
    something
  end
  ```
