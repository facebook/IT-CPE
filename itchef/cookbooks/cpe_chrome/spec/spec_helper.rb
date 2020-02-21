# Copyright (c) Facebook, Inc. and its affiliates.
#
require 'rspec'
require_relative '../libraries/windows_chrome_setting'
require_relative '../libraries/chrome_windows'

RSpec.configure do |config|
  config.include CPE::ChromeManagement
  config.disable_monkey_patching!
  config.order = :random
  config.default_formatter = 'doc'
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
