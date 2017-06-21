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

default['cpe_choco'] = {
  'bootstrap' => {
    'installation_uri' => 'https://chocolatey.org/install.ps1',
    'upgrade_source' => 'https://chocolatey.org/api/v2',
    'version' => '0.10.3',
    'choco_download_url' => 'https://chocolatey.org/api/v2/Packages()?' +
      '$filter=((Id%20eq%20%27chocolatey%27)' +
      '%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion',
    'zip_location' => 'https://chocolatey.org/7za.exe',
    # VV Must be a string since that is what the script is looking for!
    'use_windows_compression' => 'true',
  },
  'install' => {},
  'uninstall' => {},
  'source_blacklist' => [],
  'default_feed' => 'https://chocolatey.org/api/v2',
  'sources' => {
    'chocolatey' => {
      'source' => 'https://chocolatey.org/api/v2',
    },
  },
  'config' => {
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
      'description' => 'Default timeout for web requests. Available in ' +
      '0.9.10+.',
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
  },
  'features' => {
    'checksumFiles' => {
      'enabled' => true,
      'setExplicitly' => true,
      'description' => 'Checksum files when pulled in from internet (based ' +
      'on package).',
    },
    'autoUninstaller' => {
      'enabled' => true,
      'setExplicitly' => true,
      'description' => 'Uninstall from programs and features without ' +
      'requiring an explicit uninstall script.',
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
      'description' => 'Fail if install provider writes to stderr. ' +
      'Available in 0.9.10+.',
    },
    'powershellHost' => {
      'enabled' => true,
      'setExplicitly' => true,
      'description' => "Use Chocolatey's built-in PowerShell host. " +
      'Available in 0.9.10+.',
    },
    'logEnvironmentValues' => {
      'enabled' => false,
      'setExplicitly' => true,
      'description' => 'Log Environment Values - will log values of ' +
        'environment before and after install (could disclose sensitive data' +
        '). Available in 0.9.10+.',
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
        'when a license is expired or not applied to a machine. Available ' +
        'in 0.9.10+.',
    },
    'ignoreInvalidOptionsSwitches' => {
      'enabled' => true,
      'setExplicitly' => true,
      'description' => 'Ignore Invalid Options/Switches - If a switch or ' +
        'option is passed that is not recognized, should choco fail? ' +
        'Available in 0.9.10+.',
    },
    'usePackageExitCodes' => {
      'enabled' => true,
      'setExplicitly' => true,
      'description' => 'Use Package Exit Codes - Package scripts can provide ' +
        'exit codes. With this on, package exit codes will be what choco ' +
        'uses for exit when non-zero (this value can come from a dependency ' +
        'package). Chocolatey defines valid exit codes as 0, 1605, 1614, 1641' +
        ', 3010. With this feature off, choco will exit with a 0 or a 1 ' +
        '(matching previous behavior). Available in 0.9.10+.',
    },
    'useFipsCompliantChecksums' => {
      'enabled' => false,
      'setExplicitly' => true,
      'description' => 'Use FIPS Compliant Checksums - Ensure checksumming ' +
      'done by choco uses FIPS compliant algorithms. Not recommended unless ' +
      'required by FIPS Mode. Enabling on an existing installation could ' +
      'have unintended consequences related to upgrades/uninstalls. Available' +
      ' in 0.9.10+.',
    },
    'allowEmptyChecksums' => {
      'enabled' => false,
      'setExplicitly' => true,
      'description' => 'Allow packages to have empty/missing checksums for ' +
      'downloaded resources from non-secure locations (HTTP, FTP). Enabling ' +
      'is not recommended if using sources that download resources from the ' +
      'internet. Available in 0.10.0+.',
    },
    'allowEmptyChecksumsSecure' => {
      'enabled' => false,
      'setExplicitly' => true,
      'description' => 'Allow packages to have empty/missing checksums for ' +
      'downloaded resources from secure locations (HTTPS). Available in ' +
      '0.10.0+.',
    },
    'scriptsCheckLastExitCode' => {
      'enabled' => false,
      'setExplicitly' => true,
      'description' => 'Scripts Check $LastExitCode (external commands) - ' +
      'Leave this off unless you absolutely need it while you fix your ' +
      'package scripts  to use `throw \'error message\'` or ' +
      '`Set-PowerShellExitCode #` instead of `exit #`. This behavior started ' +
      'in 0.9.10 and produced hard to find bugs. If the last external process' +
      ' exits successfully but with an exit code of not zero, this could ' +
      'cause hard to detect package failures. Available in 0.10.3+. Will be ' +
      'removed in 0.11.0.',
    },
  },
}
