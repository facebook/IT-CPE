cpe_prompt_user Cookbook
========================
This cookbook adds a custom resource for prompting users.

Requirements
------------
* Mac OS X
* CocoaDialog

Attributes
------------
* node['cpe_prompt_user']['CocoaDialog']
* node['cpe_prompt_user']['icon'] 


Resources/Providers
-------------------

**cpe_prompt_user**
* This resource's purpose is to prompt the user with a provided message

**Actions**
* `:prompt` - action to prompt the user with a dialog

**Properties**
* `prompt_name`, String
* `message`, String

**Properties - Optional**
* `float`, `[ TrueClass, FalseClass ]`, default: true - do you want the prompt to be
above all other windows
* `icon`, `String`, default: node['cpe_prompt_user']['icon'] - icon in prompt
* `interval`, `[ Integer, FalseClass ]`, default: false - interval in which the
prompt will fire. If false it will only prompt once.
* `no_cancel`, `[ TrueClass, FalseClass ]`, default: true - do you wnat there to ba
a cancel button
* `title`, `String`, default: 'Facebook IT Says:' # title, text
* `type`, `String`, default: 'ok-msgbox' - working on multiple propmts


Usage
-----

In your company init cookbook's recipe, make sure to set the CocoaDialog bin path and icon path. 

    node.default['cpe_prompt_user']['CocoaDialog'] = '/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog'
    node.default['cpe_prompt_user']['icon'] = '/Library/icons/it.icns'

If you need to prompt the current user, the resource name should be short
and sweet and not contain special characters.

    cpe_prompt_user 'stuff prompt' do
      title 'Facbook IT Says:'
      message 'stuff'
    end

If you would like to prompt at an interval pass interval in minutes

    cpe_prompt_user 'stuff prompt' do
      title 'Facbook IT Says:'
      message 'stuff'
      interval 10
    end

