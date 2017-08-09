# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: remote
# Libraries:: helpers
#
# Author: Mike Dodge <mikedodge04@fb.com>
# Copyright 2014, Facebook
#
# All rights reserved - Do Not Redistribute

def get_server
  # If the distro isn't defined, set server to 'prn'
  # If the distro is defined, set server to it
  if defined? node['cpe']['network']['distro_server']
    server = node['cpe']['network']['distro_server']
  else
    if platform?('mac_os_x', 'windows')
      Chef::Log.warn("Can't get Distro for client, Falling back to prn")
    end
    server = 'prn-cpespace.thefacebook.com'
  end

  server
end

def gen_url(server, path, file)
  return "https://#{server}/chef/#{path}/#{file}"
end

def valid_url?(url)
  require 'chef/http/simple'
  http = Chef::HTTP::Simple.new(url)
  # CHEF-4762: we expect a nil return value from Chef::HTTP for a
  # "200 Success" response and false for a "304 Not Modified" response
  http.head(url)
  true
rescue
  Chef::Log.warn("INVALID URL GIVEN: #{url}")
  false
end
