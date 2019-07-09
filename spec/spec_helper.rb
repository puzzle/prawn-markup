require 'simplecov'
SimpleCov.start
SimpleCov.coverage_dir 'spec/coverage'

require 'bundler/setup'
require 'prawn/markup'

require 'logger'
Prawn::Markup::Processor.logger = Logger.new(STDOUT)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
