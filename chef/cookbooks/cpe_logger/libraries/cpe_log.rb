module CPE
  class Log
    def self.log(msg, level: :info, type: 'chef', action: nil, status: nil)
      fail_msg = 'status != success or fail'
      fail fail_msg unless %w{success fail}.include?(status) || status.nil?
      action = " action: #{action};" if action
      status = " status: #{status};" if status
      Chef::Log.send(level, "#{type};#{action}#{status} #{msg}")
      return unless RUBY_PLATFORM.include?('darwin')
      ::File.write(
        '/var/log/cpe_logger.log',
        "#{Time.now}; type: #{type};#{action}#{status} msg: #{msg};\n",
        :mode => 'a',
      )
    end

    def self.if(msg, level: :info, type: 'chef', action: nil, status: nil)
      y = block_given? ? yield : nil
      if y
        CPE::Log.log(
          msg,
          :level => level,
          :type => type,
          :action => action,
          :status => status,
        )
      end
      y
    end

    def self.unless(msg, level: :info, type: 'chef', action: nil, status: nil)
      y = block_given? ? yield : nil
      unless y
        CPE::Log.log(
          msg,
          :level => level,
          :type => type,
          :action => action,
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
        :status => status,
      )
      y
    end
  end
end
