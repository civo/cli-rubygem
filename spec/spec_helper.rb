require "bundler/setup"
require "civo_cli"
require "helpers"
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Helpers

  config.full_backtrace = true

  config.before do
    reset_dummy_cli_config
    ENV["CIVO_API_VERSION"] = "2"
    ENV["CIVO_TOKEN"] = "not-used"
    ENV["CIVO_URL"] = "https://api.example.com"
  end
end
