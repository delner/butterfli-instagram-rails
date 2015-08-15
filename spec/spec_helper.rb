$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

ENV["RAILS_ENV"] = "test"

# Load dependencies
require 'rubygems'
require 'pry'
require 'webmock/rspec'
require 'vcr'
require 'butterfli-instagram-rails'

# Testing extensions
require 'butterfli/rails/test'
require 'butterfli/instagram/test'

# Load the dummy app, to test the engine with
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../spec/dummy/db/migrate", __FILE__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)

require 'rspec/rails'

# Run any available migrations
# ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
# ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load database & schema
# ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
# load "spec/db/schema.rb"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/outbound"
  config.hook_into :webmock
  config.hook_into :faraday
end

# Load any Rspec suite support files
Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.include Butterfli::Rails::Test # Adds fixtured request helpers
  config.include Butterfli::Instagram::Test # Adds configuration helpers
end


