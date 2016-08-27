#
# Cookbook Name:: cpe_hosts
# Resource:: cpe_hosts
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

resource_name :cpe_hosts
default_action :run
action :run do
  require 'English'
  LINE_MARKER = ' # Chef Managed' + $RS
  HOSTS_FILE = '/etc/hosts'
  host_entries = node['cpe_hosts']['extra_entries'].reject do |_k, v|
    v.nil? || v.empty?
  end
  lines = ::File.readlines(HOSTS_FILE).
          select { |line| !line.end_with?(LINE_MARKER) }
  unless host_entries.empty?
    host_entries.each do |ip, names|
      entry = ip + ' ' + names.join(' ')
      lines.push(entry + LINE_MARKER)
    end
  end
  # Write out the new `/etc/hosts` file using the normal chef machinery.
  # The defaults for `file` will only write the file if the contents has
  # changed, and will do so atomically.
  file HOSTS_FILE do
    content lines.join
  end
end
