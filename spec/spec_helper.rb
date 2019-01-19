require "bundler/setup"
require "weimark"
require "vcr"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  VCR.configure do |c|
    c.cassette_library_dir = "test/fixtures"
    c.hook_into :webmock
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
