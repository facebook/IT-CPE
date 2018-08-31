# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_choco
# Resource:: cpe_choco_apps
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
# rubocop:disable Metrics/BlockLength
resource_name :cpe_choco_apps
default_action :change

action :change do
  process_lists
  @removals.each do |name, opts|
    validate_opts(opts)
    process_remove(name, opts)
  end
  @installs.each do |name, opts|
    validate_opts(opts)
    process_install(name, opts)
  end
end

# Capture some more meaningful information for a top-level message that is
# easier to read. The string is built, and then returned with the original
# exception on a new line.
def custom_exception_message(e)
  pkg_fail_re = /chocolatey_package\[(?<pkg>\w+)\]/
  case e.class
  when Mixlib::ShellOut::ShellCommandFailed
    pkg_fail = pkg_fail_re.match(e.to_s)
    exit_code = /, but received '(?<code>\d+)'/.match(e.to_s)
    format(
      "%s failed with exit code %s\n%s",
      pkg_fail.to_s,
      exit_code[:code],
      e.to_s,
    )
  when ::NoMethodError
    pkg_fail = pkg_fail_re.match(e.to_s)
    format(
      "%s failed to install package '%s' with a NoMethod exception\n%s",
      self,
      pkg_fail[:pkg],
      e.to_s,
    )
  end

  e.to_s
end

action_class do
  NO_OPTIONS = '%s was not passed as a key/value pair'
  NO_VERSION = '%s was not passed a `version` and will not be installed'

  def validate_opts(opts)
    if !opts.is_a?(Hash)
      fail ::Chef::Exceptions::InvalidResourceReference,
           format(NO_OPTIONS, name)
    elsif opts['version'].nil?
      fail ::Chef::Exceptions::InvalidVersionConstraint,
           format(NO_VERSION, name)
    end
  end

  def process_install(name, options)
    chocolatey_package name do |pkg| # ~FC009
      provider_supported_opts(options, pkg)
      version version_guard(options)
      action action_guard(options)
    end
  end

  def provider_supported_opts(options, pkg)
    %w{
      timeout
      options
      source
      retries
      retry_delay
      notifies
      subscribes
      prerelease
    }.each do |opt|
      next if options[opt].nil?
      pkg.set_or_return(opt.to_sym, options[opt], {})
    end
  end

  def action_guard(option)
    if option['version'].casecmp('latest').zero?
      :upgrade
    end
    :install
  end

  def version_guard(option)
    if option['version'].casecmp('latest').zero?
      nil
    end
    option['version']
  end

  def process_lists
    @installs = node['cpe_choco']['install'].to_hash
    @removals = node['cpe_choco']['uninstall'].to_hash
  end

  def process_remove(name, options)
    @installs.delete_if { |k, _| k == name }

    chocolatey_package name do |pkg|
      provider_supported_opts(options, pkg)
      action :remove
    end
  end
end
