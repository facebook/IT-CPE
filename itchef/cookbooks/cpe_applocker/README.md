cpe_applocker Cookbook
====================
About
--------------------
This cookbook includes recipes and resources to install, configure, and manage
Windows AppLocker. AppLocker is a binary application allowlisting and
blacklisting service built natively into Windows. AppLocker allows for
Blacklisting or allowlisting via signing certificate, binary path, and binary
hash.

Supported Platforms
--------------------

* Windows 10

Chef
--------------------

* Chef 14

Usage
--------------------
* Include `cpe_applocker::default` in your node's run_list
* Override attributes to match your desired AppLocker configuration, see the
  table below for configuration options.

Recipes
--------------------

### default
The `default` recipe determines if the platform can support AppLocker, and, if
configured, will enable the `AppIDSvc` service and configure the applocker
rules specified by the attributes.

Attributes
--------------------

Use the following attributes to manage and configure AppLocker

| name   | type | default |                   description                     |
|--------|------|---------|---------------------------------------------------|
| `['cpe_applocker']['enabled']` | `Boolean` | `nil` | Whether to configure AppLocker. `true` => Install and Configure, `false` => Uninstall, `nil` => Do nothing, used for GPO AD managed AppLocker hosts. |
| `['cpe_applocker']['applocker_rules']` | `Hash` | A hash with all empty rule sets | A hash containing the AppLocker rules, see the next section for configuring rules |

### AppLocker Hash rule configuration

**Note** it is strongly encouraged that users of this cookbook read through the
[MSDN technet articles](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/administer-applocker)
on managing and configuring AppLocker, and leverage the
[Powershell Cmdlets for generating AppLocker rules](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/use-the-applocker-windows-powershell-cmdlets).

The AppLocker rules are specified by a ruby Hash, which is converted to and
from an XML blob to be shipped to AppLocker via the `Nokogiri::XML` parser.
There are 5 total rule sets one can configured,
[completely detailed in this MSDN article](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/working-with-applocker-rules#rule-collections).
In short, one can control the exection of the following types of applications
on a windows host:

* Executable Files: `.exe`, `.com`
* Scripts: `.ps1`, `.bat`, `.cmd`, `.vbs`, `.js`
* Windows Installer Files: `.msi`, `.msp`, `.mst`
* Packaged Apps and App installers: `.appx`
* DLL Files: `.dll`, `.ocx`

The ruby Hash containing the rule sets has a sub-Hash for each of the
application types. Each subhash contains an array called `rules` which is a
list of Hashes, where each Hash represents an individual AppLocker rule.

Let's look at a trivial example containing one of the default AppLocker rules
for allowing any executable to run for Administrators. The rule as it looks
when pulled from the AppLocker policy is:

```xml
<AppLockerPolicy Version="1">
  <RuleCollection Type="Appx" EnforcementMode="AuditOnly" />
  <RuleCollection Type="Dll" EnforcementMode="AuditOnly" />
  <RuleCollection Type="Exe" EnforcementMode="AuditOnly">
    <FilePathRule Id="fd686d83-a829-4351-8ff4-27c7de5755d2" Name="(Default
      Rule) All files" Description="Allows members of the local Administrators
      group to run all applications." UserOrGroupSid="S-1-5-32-544"
      Action="Allow">
      <Conditions>
        <FilePathCondition Path="*" />
      </Conditions>
    </FilePathRule>
  </RuleCollection>
  <RuleCollection Type="Msi" EnforcementMode="AuditOnly" />
  <RuleCollection Type="Script" EnforcementMode="AuditOnly" />
</AppLockerPolicy>
```

We then convert this XML hash into a Ruby Hash, so it can fit nicely into our
`applocker_rules` attribute:

```ruby
'applocker_rules' => {
    'Appx' => {'mode' => 'AuditOnly', 'rules' => []},
    'Dll' => {'mode' => 'AuditOnly', 'rules' => []},
    'Exe' => {
      'mode' => 'AuditOnly',
      'rules' => [
        {
          'type' => 'path',
          'name' => '(Default Rule) All files',
          'id' => 'fd686d83-a829-4351-8ff4-27c7de5755d2',
          'description' => 'Allows members of the local Administrators ' +
            'group to run all applications.',
          'user_or_group_sid' => 'S-1-5-32-544',
          'action' => 'Allow',
          'conditions' => [
            { 'path' => '*' },
          ],
        },
      ],
    },
    'Msi' => {'mode' => 'AuditOnly', 'rules' => []},
    'Script' => {'mode' => 'AuditOnly', 'rules' => []},
```

When our cook book runs, it will render the above Ruby hash to be the same XML
blob that AppLocker is expecting. Let's look a bit closer at the hash rule we
have defined above to better understand what each key/value pair should be:

| Key | Value |
|-----|-------|
|`type` | This is the type of AppLocker rule, can be one of `path`, `certificate`, or `hash`. |
|`name` | A descriptive name for the rule. There are no restrictions on this, but it's encouraged to use a descriptive name. |
| `id`  | This is a GUID value to uniquely identify the rule. You can fetch a new Guid with the `New-Guid` powershell cmdlet, or use the local AppLocker rule generation flow to get a GUID for your rule. |
| `description` | A more exhaustive description of your rule, perhaps a great place to link policy decisions for why the app is blocked. |
| `user_or_group_sid` | The SID which identifies the user or group that this rule should apply to, for example `S-1-1-0` is the "Everyone" group. Can be fetched with a utility like osquery, or via WMIC with `wmic useraccount where name='username' get sid`. |
| `action` | Whether to allow or deny the execution, must be one of `Allow` or `Deny`. |
| `conditions` | A list of hashes specifying the particulars of this rule. For paths this is a Hash of the path values, such as `[{'path' => 'C:\ProgramData\*'}]`. Paths support wildcards, see [this MSDN article](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/working-with-applocker-rules) for more details on these values. |
