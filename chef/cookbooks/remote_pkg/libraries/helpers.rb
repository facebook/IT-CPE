#
# Cookbook Name:: remote
# Libraries:: helpers
#
# Author: Mike Dodge <mikedodge04@fb.com>
# Copyright 2016, Facebook
#
# All rights reserved - Do Not Redistribute

def get_server
  # We have multiple servers and us this funtion
  # to determine which server a given client should
  # be pointed to based on the location. 
  server = "THIS_SHOULD_YOUR_WEB_SERVER"
  server
end

def gen_url(server, path, file)
  username = node['remote']['username']
  pass = node['remote']['pass']
  user_pass = "#{username}:#{pass}@"
  pkg_url = "https://#{user_pass}#{server}/chef/#{path}/#{file}"
  pkg_url
end

def valid_url?(url, msg = '')
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
