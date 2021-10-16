# frozen_string_literal: true

require 'nomics'
require 'webmock/rspec'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'vcr'
VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/cassettes'
end

NOMICS_API_KEY = 'f01b50e37d66089f206b74732b0a9d60caed6ecc'.freeze

Nomics.configure do |config|
  config.api_key = NOMICS_API_KEY
end
