# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Cookbook Name:: cpe_nightly_reboot
# Recipe:: default
#
# Copyright 2016, Facebook CPE
#
# All rights reserved - Do Not Redistribute
#

restart_launchd = {
  'program_arguments' => [
    '/sbin/reboot'
  ],
  'start_calendar_interval' => {}
}

logout_launchd = {
  'program_arguments' => [
    '/Library/CPE/lib/flib/scripts/logout_bootstrap.py'
  ],
  'start_calendar_interval' => {}
}

interval_hash = {}
logout_hash = {}

ruby_block 'restart' do
  block do
    interval_hash =
      node['cpe_nightly_reboot']['restart'].reject { |_k, v| v.nil? }
    unless interval_hash.empty?
      restart_launchd['start_calendar_interval'] = interval_hash
      node.default['cpe_launchd']['com.CPE.reboot'] =
        restart_launchd
    end
    logout_hash = node['cpe_nightly_reboot']['logout'].reject { |_k, v| v.nil? }
    unless logout_hash.empty?
      logout_launchd['start_calendar_interval'] = logout_hash
      node.default['cpe_launchd']['com.CPE.logout'] =
        logout_launchd
    end
  end
  action :run
end
