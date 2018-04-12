#
# Cookbook Name:: cpe_nomad
# Library:: nomad_helpers
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

module CPE
  module Nomad
    def console_user
      @console_user ||= CPE::Utils.console_user
    end

    def demobilize
      dscl = '/usr/bin/dscl'

      # Gather current auth authorities
      dscl_out = shell_out(
        "#{dscl} -plist . -read /Users/#{console_user} " +
        'dsAttrTypeNative:authentication_authority',
      )

      auths = Plist.parse_xml(
        dscl_out.stdout,
      ).fetch('dsAttrTypeNative:authentication_authority', nil)

      log_vars('verify', 'fail')
      msg = "Cannot find auth authorities for #{console_user}"
      return if log_if(msg) { auths.nil? || auths.empty? }

      log_vars('verify', 'success')
      msg = "Found Active Directory attribute for #{console_user}"
      return unless log_if(msg) do
                      auths.any? do |i|
                        i.include? ';LocalCachedUser;/Active Directory'
                      end ? true : false
                    end

      error_free = true
      log_vars('execute', 'fail')
      # Remove AD attributes
      [
        'dsAttrTypeStandard:CopyTimestamp',
        'dsAttrTypeStandard:AltSecurityIdentities',
        'dsAttrTypeStandard:OriginalAuthenticationAuthority',
        'dsAttrTypeStandard:OriginalNodeName',
        'dsAttrTypeStandard:SMBSID',
        'dsAttrTypeStandard:SMBScriptPath',
        'dsAttrTypeStandard:SMBPasswordLastSet',
        'dsAttrTypeStandard:SMBGroupRID',
        'dsAttrTypeStandard:SMBPrimaryGroupSID',
        'dsAttrTypeStandard:PrimaryNTDomain',
        'dsAttrTypeStandard:AppleMetaRecordName',
        'dsAttrTypeStandard:MCXSettings',
        'dsAttrTypeStandard:MCXFlags',
        'dsAttrTypeNative:accountPolicyData',
        'dsAttrTypeNative:authentication_authority',
        'dsAttrTypeNative:cached_groups',
        'dsAttrTypeNative:cached_auth_policy',
      ].each do |attribute|
        cmd = "#{dscl} . -delete /Users/#{console_user} #{attribute}"
        error_free = false if log_if("Executing: #{cmd}") do
          shell_out(cmd).error?
        end
      end

      # Update authentication authorities
      auths.each do |auth|
        unless auth.include?(';LocalCachedUser;/Active Directory')
          cmd = "#{dscl} . -append /Users/#{console_user} " +
                'dsAttrTypeNative:authentication_authority ' +
                "'#{auth}'"
          error_free = false if log_if("Executing: #{cmd}") do
            shell_out(cmd).error?
          end
        end
      end

      # Update group membership
      [
        'admin',
        'staff',
        '_lpadmin',
      ].each do |group_name|
        group "#{cookbook_name}-#{group_name}" do # ~FB015
          group_name group_name
          members console_user
          append true
          action :modify
        end
      end

      return unless log_if_else(
        'Demobilizer succeeded', 'Demobilizer failed'
      ) do
        error_free
      end

      # Remove the cached .account file for a mobile user
      file "/Users/#{console_user}/.account" do
        backup false
        action :delete
      end
    end

    def log_vars(action, status)
      @type = 'cpe_nomad'
      @action = action
      @status = status
    end

    def log_if_else(ifmsg, elsemsg)
      CPE::Log.if_else(
        ifmsg, elsemsg, :type => @type, :action => @action
      ) { yield }
    end

    def log_if(msg)
      CPE::Log.if(
        msg, :type => @type, :action => @action, :status => @status
      ) { yield }
    end

    def log_unless(msg)
      CPE::Log.unless(
        msg, :type => @type, :action => @action, :status => @status
      ) { yield }
    end
  end
end
