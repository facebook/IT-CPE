# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_choco
# Attributes:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

default['cpe_choco'] = {}
default['cpe_choco']['app_cache'] = 
  format('%s\config\choco_req_apps.json', ENV['ChocolateyInstall'])
default['cpe_choco']['installation_uri'] = 'https://chocolatey.org/install.ps1'
default['cpe_choco']['installs'] = {}
default['cpe_choco']['source_blacklist'] = []
default['cpe_choco']['default_feed'] = 'chocolatey'
default['cpe_choco']['sources'] = {
  'chocolatey' => {
    'source' => 'https://chocolatey.org/api/v2',
  },
}
default['cpe_choco']['config'] = {
  'cacheLocation' => {
    'value' => '',
    'description' => 'Cache location if not TEMP folder.',
  },
  'commandExecutionTimeoutSeconds' => {
    'value' => 2700,
    'description' => 'Default timeout for command execution.',
  },
  'webRequestTimeoutSeconds' => {
    'value' => 30,
    'description' => 'Default timeout for web requests. Available in 0.9.10+.',
  },
  'containsLegacyPackageInstalls' => {
    'value' => true,
    'description' => 'Install has packages installed prior to 0.9.9 series.',
  },
  'proxy' => {
    'value' => '',
    'description' => 'Explicit proxy location.',
  },
  'proxyUser' => {
    'value' => '',
    'description' => 'Optional proxy user.',
  },
  'proxyPassword' => {
    'value' => '',
    'description' => 'Optional proxy password. Encrypted.',
  },
}
default['cpe_choco']['features'] = {
  'checksumFiles' => {
    'enabled' => true,
    'setExplicitly' => true,
    'description' => 'Checksum files when pulled in from internet (based on ' +
    'package).',
  },
  'autoUninstaller' => {
    'enabled' => true,
    'setExplicitly' => true,
    'description' => 'Uninstall from programs and features without requiring ' +
    'an explicit uninstall script.',
  },
  'allowGlobalConfirmation' => {
    'enabled' => false,
    'setExplicitly' => true,
    'description' => 'Prompt for confirmation in scripts or bypass.',
  },
  'failOnAutoUninstaller' => {
    'enabled' => true,
    'setExplicitly' => true,
    'description' => 'Fail if automatic uninstaller fails.',
  },
  'failOnStandardError' => {
    'enabled' => true,
    'setExplicitly' => true,
    'description' => 'Fail if install provider writes to stderr. Available in' +
    ' 0.9.10+.',
  },
  'powershellHost' => {
    'enabled' => true,
    'setExplicitly' => true,
    'description' => "Use Chocolatey's built-in PowerShell host. Available in" +
    ' 0.9.10+.',
  },
  'logEnvironmentValues' => {
    'enabled' => false,
    'setExplicitly' => true,
    'description' => 'Log Environment Values - will log values of ' +
      'environment before and after install (could disclose sensitive data). ' +
      'Available in 0.9.10+.',
  },
  'virusCheck' => {
    'enabled' => false,
    'setExplicitly' => true,
    'description' => 'Virus Check - perform virus checking on downloaded ' +
      'files. Available in 0.9.10+. Licensed versions only.',
  },
  'failOnInvalidOrMissingLicense' => {
    'enabled' => false,
    'setExplicitly' => true,
    'description' => 'Fail On Invalid Or Missing License - allows knowing ' +
      'when a license is expired or not applied to a machine. Available in ' +
      '0.9.10+.',
  },
  'ignoreInvalidOptionsSwitches' => {
    'enabled' => true,
    'setExplicitly' => true,
    'description' => 'Ignore Invalid Options/Switches - If a switch or ' +
      'option is passed that is not recognized, should choco fail? Available ' +
      'in 0.9.10+.',
  },
  'usePackageExitCodes' => {
    'enabled' => true,
    'setExplicitly' => true,
    'description' => 'Use Package Exit Codes - Package scripts can provide ' +
      'exit codes. With this on, package exit codes will be what choco uses ' +
      'for exit when non-zero (this value can come from a dependency package)' +
      '. Chocolatey defines valid exit codes as 0, 1605, 1614, 1641, 3010. ' +
      'With this feature off, choco will exit with a 0 or a 1 (matching ' +
      'previous behavior). Available in 0.9.10+.',
  },
  'useFipsCompliantChecksums' => {
    'enabled' => false,
    'setExplicitly' => true,
    'description' => 'Use FIPS Compliant Checksums - Ensure checksumming done' +
    ' by choco uses FIPS compliant algorithms. Not recommended unless ' +
    'required by FIPS Mode. Enabling on an existing installation could have ' +
    'unintended consequences related to upgrades/uninstalls. Available in ' +
    '0.9.10+.',
  },
}
