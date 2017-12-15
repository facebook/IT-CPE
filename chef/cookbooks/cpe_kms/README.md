cpe_kms Cookbook
===================
This cookbook manages the KMS Settings on Windows machines.

Attributes
----------
* node['cpe_kms']['KeyManagementServiceName']
* node['cpe_kms']['KeyManagementServicePort']


Usage
-----
Manages the KMS server and port configuration on Windows systems.  
node['cpe_kms']['KeyManagementServiceName'] sets the KMS server name.
node['cpe_kms']['KeyManagementServicePort'] sets the KMS server port

For example, to set the KMS server and port name, just override the attribute

    node.default['cpe_kms'] = {
      'KeyManagementServiceName' => 'my.kms.server',
      'KeyManagementServicePort' => '1234'
    }
