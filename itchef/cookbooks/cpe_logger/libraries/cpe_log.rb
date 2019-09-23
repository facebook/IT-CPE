# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module CPE
  class Log
    def self.log_path
      unix_log = '/var/log/cpe_logger.log'
      win_log = 'C:\Windows\cpe\logs\cpe_logger.log'
      RUBY_PLATFORM.include?('w32') ? win_log : unix_log
    end

    # rubocop:disable Metrics/ParameterLists
    def self.log(
      msg,
      level: :info,
      type: 'chef',
      action: nil,
      actor: nil,
      status: nil
    )
      fail_msg = 'status != success or fail'
      fail fail_msg unless %w{success fail}.include?(status) || status.nil?
      action = " action: #{action};" if action
      actor = " actor: #{actor};" if actor
      status = " status: #{status};" if status
      # Replace newlines to prevent null values written to scuba table
      msg = msg.to_s.tr("\n", ' ')
      Chef::Log.send(level, "#{type};#{action}#{actor}#{status} #{msg}")
      if Dir.exist?(File.dirname(log_path))
        ::File.write(
          log_path,
          "#{Time.now}; type: #{type};#{action}#{status} msg: #{msg};\n",
          :mode => 'a',
        )
      end
    end

    def self.if(
      msg,
      level: :info,
      type: 'chef',
      action: nil,
      actor: nil,
      status: nil
    )
      y = block_given? ? yield : nil
      if y
        CPE::Log.log(
          msg,
          :level => level,
          :type => type,
          :action => action,
          :actor => actor,
          :status => status,
        )
      end
      y
    end

    def self.unless(
      msg,
      level: :info,
      type: 'chef',
      action: nil,
      actor: nil,
      status: nil
    )
      y = block_given? ? yield : nil
      unless y
        CPE::Log.log(
          msg,
          :level => level,
          :type => type,
          :action => action,
          :actor => actor,
          :status => status,
        )
      end
      y
    end

    # rubocop:disable Metrics/ParameterLists
    def self.if_else(
        ifmsg,
        elsemsg,
        level: :info,
        type: 'chef',
        action: nil,
        actor: nil,
        ifstatus: 'success',
        elsestatus: 'fail'
    )
      y = block_given? ? yield : nil
      msg = y ? ifmsg : elsemsg
      status = y ? ifstatus : elsestatus
      CPE::Log.log(
        msg,
        :level => level,
        :type => type,
        :action => action,
        :actor => actor,
        :status => status,
      )
      y
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
