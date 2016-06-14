cpe_profiles Cookbook
=========================
This is a cookbook that will manage all of the configuration profiles used with
chef.

Requirements
------------
Mac OS X


Attributes
----------
* node['cpe_profiles']
* node['cpe_profiles']['prefix']

Usage
-----
Include this recipe and add any configuration profiles in the format in the
example below.

**Note:** Ensure that you override the default value of `node['cpe_profiles']['prefix']`. 
If you do not do this, it will assume an identifier prefix of `com.facebook.chef`.


**THIS MUST GO IN A RECIPE. DO NOT PUT THIS IN ATTRIBUTES, OR IT MAY CAUSE PAIN
AND SUFFERING FOR YOUR FLEET!**

To add a new config profile, in your recipe, add a key matching the 
profile identifier with a value that contains the hash of the profile
to `node.default['cpe_profiles']`

For instance, add a hash to manage the screensaver and use the default prefix: 

    node.default['cpe_profiles']['com.facebook.chef.screensaver'] = {
      'PayloadIdentifier' => 'com.facebook.chef.screensaver',
      'PayloadRemovalDisallowed' => true,
      'PayloadScope' => 'System',
      'PayloadType' => 'Configuration',
      'PayloadUUID' => 'E257207C-17F4-4FE7-B287-3F111D60FF50',
      'PayloadOrganization' => 'Facebook',
      'PayloadVersion' => 1,
      'PayloadDisplayName' => 'Settings for Nate',
      'PayloadContent'=> [
        {
          'PayloadType' => 'com.apple.ManagedClient.preferences',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => 'com.cpe.nwalck.settings',
          'PayloadUUID' => 'AC66C802-DE14-4C92-8BFE-2369FFA8D029',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'Custom: (com.apple.screensaver)',
          'PayloadContent' => {
            'com.apple.screensaver' => {
              'Forced' => [
                {
                  'mcx_preference_settings' => {
                    'idleTime' => 600,
                    'askForPassword' => 1,
                    'askForPasswordDelay' => 0.0,
                  }
                }
              ]
            }
          }
        }
      ]
    }


**If you already have profiles installed using an existing prefix, be sure to 
convert all of them over to the new prefix. There will be pain and suffering if this
is not done.**

Or, if you want to customize the prefix and then add a profile, you would do:

    # Override the default prefix value of 'com.facebook.chef'
    node.default['cpe_profiles']['prefix'] = 'com.company.chef'
    # Use the specified prefix to name the configuration profile
    node.default['cpe_profiles']['com.company.chef.screensaver'] = {
      'PayloadIdentifier' => 'com.company.chef.screensaver',
      'PayloadRemovalDisallowed' => true,
      'PayloadScope' => 'System',
      'PayloadType' => 'Configuration',
      'PayloadUUID' => 'E257207C-17F4-4FE7-B287-3F111D60FF50',
      'PayloadOrganization' => 'Company',
      'PayloadVersion' => 1,
      'PayloadDisplayName' => 'Settings for screensaver',
      'PayloadContent'=> [
        {
          'PayloadType' => 'com.apple.ManagedClient.preferences',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => 'com.cpe.nwalck.settings',
          'PayloadUUID' => 'AC66C802-DE14-4C92-8BFE-2369FFA8D029',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'Custom: (com.apple.screensaver)',
          'PayloadContent' => {
            'com.apple.screensaver' => {
              'Forced' => [
                {
                  'mcx_preference_settings' => {
                    'idleTime' => 600,
                    'askForPassword' => 1,
                    'askForPasswordDelay' => 0.0,
                  }
                }
              ]
            }
          }
        }
      ]
    } 

