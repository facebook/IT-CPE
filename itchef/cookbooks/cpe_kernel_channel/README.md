cpe_kernel_channel Cookbook
===========================
This cookbook configures the repository used to deliver kernel packages.

Requirements
------------
* Fedora

Attributes
----------
* node['cpe_kernel_channel']['enable']
* node['cpe_kernel_channel']['kernel_version']
* node['cpe_kernel_channel']['release']
* node['cpe_kernel_channel']['repo']

Usage
-----

* `enable`: boolean. Set to `true` to enable this cookbook
* `kernel_version`: string. If set, will ensure this kernel is installed.
   Can be either the version or the version and release e.g. '4.18.0'
* `repo`: string. Currently either 'fedora' or 'centos'
* `release`: string. e.g. '8-stream' to get the CentOS 8 stream,
   or '8.1.1911' for a specific release. On Fedora this is ignored
   if `repo` is set to 'fedora'.

You also might want to exclude the Fedora kernels from being available,
otherwise `dnf upgrade` will always install newer Fedora kernels so
even though you can `dnf install` a CentOS kernel it will never get
upgraded.

### Examples

#### Using the CentOS 8-Stream kernel

```
node.default['cpe_kernel_channel'] = {
  'enable' => true,
  'release' => '8-stream',
  'repo' => 'centos',
}
```

#### Version locking to exclude Fedora kernels

Either use our `cpe_package_versions` cookbook:

```
node.default['cpe_package_versions']['enable'] = true
node.default['cpe_package_versions']['enable_locking'] = true

%w{
  kernel
  kernel-core
  kernel-devel
  kernel-modules
}.each do |pkg|
  node.default['cpe_package_versions']['pkgs'][pkg] = '*-*.el8'
end
```

Or configure `/etc/dnf/plugins/versionlock.list`, after installing via:

`dnf install 'dnf-command(versionlock)'`
