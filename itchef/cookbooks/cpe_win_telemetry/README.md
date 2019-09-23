cpe_win_telemetry Cookbook
===================
This cookbook manages the telemetry settings on Windows machines. These settings
specify the amount and detail of data sent to Microsoft on a Windows node.
More information can be found here: https://docs.microsoft.com/en-us/windows/configuration/configure-windows-telemetry-in-your-organization

Attributes
----------
* node['cpe_win_telemetry']['AllowTelemetry']

Usage
-----
Manages the telemetry settings on a Windows node
node['cpe_win_telemetry']['AllowTelemetry'].

The following values can be given to this attribute.
-1 : disable telemetry completely by setting the telemetry level to '0' which
is the minimum value MS allows.  Then disables two services which the telemetry
services relies on.  These are DiagTrack and dmwappushservice.

0 : Security level. Security data only.
1 : Basic level. Everything in 0 and basic system and quality data.
2 : Enhanced level. Everything in 1 and enhanced insights and advanced
     reliability data.
3 : Full level. Everything in 2 and full diagnostics.

For example, to disable telemetry just set the attribute as follows:

    node.default['cpe_win_telemetry'] = {
      'AllowTelemetry' => -1,
    }

If nothing is set, Microsoft defaults to level 3.
