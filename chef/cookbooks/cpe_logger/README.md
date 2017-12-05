cpe_logger Cookbook
==================
This cookbook provides a central logging library that other recipes can take advantage of to provide some unified logging. All log data here is collected in /var/log/cpe/cpe_logger.log and can be collected by osquery.

Usage
-----

`CPE::Log.if(msg) { method }`
This will log the msg if the method returns truthy, and will return the value of the method call.

`CPE::Log.unless(msg) { method }`
This will log the msg unless the method returns falsy, and will return the value of the method call.

`CPE::Log.if_else(ifmsg, elsemsg) { method }`
This will log the `ifmsg` if the method returns truthy, and will log the `elsemsg` if the method returns falsy.
Additionally it will return the value of the method call.

Example usage of Log.if:
    CPE::Log.if('This is true') { true }

Example usage of Log.unless:
    CPE::Log.unless('This is true') { false }

Its highly encouraged that you also pass level, type, action, status.
  level - Symbol, [:info, :warn, :error] default: :info
  type - String, Name of cookbook. default: chef
  action - String, Name of resource/resource_action. default: nil
  status - String, [success, fail] default: nil

As well as showing the log in the chef output, these methods will produce a log
on disk at '/var/log/cpe_logger.log', which can be indexed with osquery.

# Common Constructions

It's helpful to create a helper function to set up your log variables first. With this helper function, you can set up what your log output will look like before usage:

    # Set up your log variables
    def log_vars(action, status)
      @type = 'recipe_or_resource_name'
      @action = action
      @status = status
    end

Using the `log_vars` function above makes it easier to be consistent in your messaging. Here's some sample code you can copy and paste into your cookbook:

    def log_vars(action, status)
      @type = 'cpe_filevault'
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


Now you can use this to establish the base for your future logging:

    log_vars('verify', 'fail')
    return unless log_unless('message_if_this_fails') { check_some_test? }

The output would look like this:
```
[2017-12-04T10:33:16-08:00] INFO: cookbook_name; action: verify; status: fail; message_if_this_fails
```
