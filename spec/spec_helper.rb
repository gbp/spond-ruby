require "bundler/setup"
require "spond"
require "vcr"
require "webmock/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter sensitive data
  config.filter_sensitive_data("<EMAIL>") { ENV["SPOND_EMAIL"] }
  config.filter_sensitive_data("<PASSWORD>") { ENV["SPOND_PASSWORD"] }
  config.filter_sensitive_data("<TOKEN>") { ENV["SPOND_TOKEN"] }

  # Don't allow any real HTTP connections
  config.allow_http_connections_when_no_cassette = false
end
