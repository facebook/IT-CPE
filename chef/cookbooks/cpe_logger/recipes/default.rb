# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_logger
# Recipe:: default
#
# Copyright 2016-present, Facebook
#
# All rights reserved - Do Not Redistribute
#

return unless node.macos?

node.default['cpe_splunk']['indexed_files']['/var/log/cpe_logger.log'] = {
  'sourcetype' => 'cpe_logger',
}

conf_content = <<CONF
# logfilename          [owner:group]    mode count size when  flags [/pid_file] [sig_num]
/var/log/cpe_logger.log                       644  10    500000    $D0   J   /var/run/cpe_logger.pid
CONF

file '/etc/newsyslog.d/cpe_logger.conf' do
  content conf_content
  mode '0644'
  owner 'root'
  group 'wheel'
  action :create
end
