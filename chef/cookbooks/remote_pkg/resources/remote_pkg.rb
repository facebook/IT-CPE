#
# Cookbook Name:: remote
# Resource:: pkg
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

include Chef::Mixin::ShellOut


resource_name :remote_pkg
default_action :install

property :app, :kind_of => String, :name_attribute => true
property :checksum, :kind_of => String
property :cleanup,:kind_of => [TrueClass, FalseClass], :default => true
property :installed, :kind_of => [TrueClass, FalseClass], :default => false
property :pkg_name, :kind_of => String, :default => nil
property :receipt, :kind_of => String
property :remote, :kind_of => [TrueClass, FalseClass], :default => true
property :version, :kind_of => String, :default => nil

action :install do
  unless installed?

    pkg_name = app
    pkg_version_str = "-#{version}"
    chef_cache = Chef::Config[:file_cache_path]

    pkg_file = "#{pkg_name}#{pkg_version_str}.pkg"
    pkg_file_path = "#{chef_cache}/#{pkg_file}"

    if remote
      pkg_source = gen_url(get_server, pkg_name, pkg_file)

      remote_file pkg_file do
        path pkg_file_path
        source pkg_source
        checksum checksum
        backup !cleanup
      end
    end

    execute "Installing #{pkg_file}" do
      only_if do
        # Comparing the Checksum Provided to the file downloaded
        checksum_ondisk = Chef::Digester.checksum_for_file(pkg_file_path)
        Chef::Log.debug(
          "Provided checksum #{checksum} == " +
          "File On Disk checksum #{checksum_ondisk}"
        )
        if checksum != checksum_ondisk
          fail ArgumentError, 'Invalid Checksum, Checksum Mismatch'
        end
        true
      end
      command "installer -pkg '#{pkg_file_path}' -target /"
    end

    # Delete PKG
    file pkg_file_path do
      only_if { cleanup }
      action :delete
      backup false
    end
  end
end

def installed?
  if shell_out("pkgutil --pkgs='#{receipt}'").exitstatus == 0
    cmd = "pkgutil --pkg-info '#{receipt}'"
    if shell_out(cmd).stdout.include?("version: #{version}")
      msg = "Already installed; run \"sudo pkgutil --forget '#{receipt}'\""
      Chef::Log.info(msg)
      return true
    end
  end
  return false
end

def get_server
  # We have multiple servers and us this funtion
  # to determine which server a given client should
  # be pointed to based on the location. 
  node['remote_pkg']['server']
end

def gen_url(server, path, file)
  username = node['remote']['username']
  pass = node['remote']['pass']
  user_pass = username ? "#{username}:#{pass}@" : '' 
  pkg_url = "https://#{user_pass}#{server}/chef/#{path}/#{file}"
  pkg_url
end

def valid_url?(url, msg = '')
  begin
    require 'chef/http/simple'
    http = Chef::HTTP::Simple.new(url)
    # CHEF-4762: we expect a nil return value from Chef::HTTP for a
    # "200 Success" response and false for a "304 Not Modified" response
    # If the URL is invalid it will rasie an error
    http.head(url)
    true
  rescue
    Chef::Log.warn("INVALID URL GIVEN #{msg}")
    false
  end
end


