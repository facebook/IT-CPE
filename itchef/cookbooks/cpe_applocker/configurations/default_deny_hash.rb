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
        {
          'type' => 'hash',
          'name' => 'ccleaner_backdoored_1',
          'id' => '3061cac7-ed87-4c61-a7f5-b41d725b08f2',
          'description' => 'One of the backdoored CCleaner variants',
          'user_or_group_sid' => 'S-1-1-0',
          'action' => 'Deny',
          'conditions' => [
            {
              'type' => 'SHA256',
              'data' => '0x0938F0FBA6DA55A14CCC1A7EC0E6E9E6B' +
                        '2FC694437C473551308D7C01546638D',
              'file_name' => 'ccleaner.exe',
              'file_length' => '7781592',
            },
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
