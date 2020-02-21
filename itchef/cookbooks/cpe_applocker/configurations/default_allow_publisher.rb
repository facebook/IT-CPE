# Copyright (c) Facebook, Inc. and its affiliates.
{
  'enabled' => true,

  'applocker_rules' => {
    'Appx' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
    'Dll' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
    'Exe' => {
      # Should be `AuditOnly` or `Enabled`
      'mode' => 'AuditOnly',
      'rules' => [
        {
          'type' => 'certificate',
          'name' => 'microsoft_signed',
          'id' => '40eed11e-5aa5-4e81-a9d0-630847611202',
          'description' => 'All binaries signed by Microsoft are allowed.',
          'action' => 'Allow',
          'user_or_group_sid' => 'S-1-1-0',
          'conditions' => [
            {
              'publisher' => 'O=MICROSOFT CORPORATION, L=REDMOND, ' +
                             'S=WASHINGTON, C=US',
              'product_name' => '*',
              'binary_name' => '*',
              'binary_version' => { 'low' => '*', 'high' => '*' },
            },
          ],
        },
        {
          'type' => 'certificate',
          'name' => 'facebook_signed',
          'id' => 'cf0bd1e5-b8a9-40a6-ae20-a583da23cbc4',
          'description' => 'All binaries signed by Facebook are allowed.',
          'action' => 'Allow',
          'user_or_group_sid' => 'S-1-1-0',
          'conditions' => [
            {
              'publisher' => 'O=FACEBOOK, INC., L=MENLO PARK, S=CA, C=US',
              'product_name' => '*',
              'binary_name' => '*',
              'binary_version' => { 'low' => '*', 'high' => '*' },
            },
          ],
        },
        {
          'type' => 'path',
          'name' => 'all_program_files_applications',
          'id' => '921cc481-6e17-4653-8f75-050b80acca20',
          'description' => 'Default rule for any program in Program ' +
            'Files is allowed to run',
          'user_or_group_sid' => 'S-1-1-0',
          'action' => 'Allow',
          'conditions' => [
            { 'path' => '%PROGRAMFILES%\*' },
          ],
        },
        {
          'type' => 'path',
          'name' => 'all_windows_system_applications',
          'id' => 'a61c8b2c-a319-4cd0-9690-d2177cad7b51',
          'description' => 'Default rule for any application in ' +
                           'Windows system root',
          'user_or_group_sid' => 'S-1-1-0',
          'action' => 'Allow',
          'conditions' => [
            { 'path' => '%WINDIR%\*' },
          ],
        },
        {
          'type' => 'path',
          'name' => 'administrators_full_access',
          'id' => 'fd686d83-a829-4351-8ff4-27c7de5755d2',
          'description' => 'Default catch all, Administrators can run anything',
          'user_or_group_sid' => 'S-1-5-32-544',
          'action' => 'Allow',
          'conditions' => [
            { 'path' => '*' },
          ],
        },
      ],
    },
    'Msi' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
    'Script' => {
      'mode' => 'AuditOnly',
      'rules' => [],
    },
  },
}
