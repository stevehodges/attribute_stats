require 'support/database'
require 'rails/all'

module DummyApp
  class Application < Rails::Application
    config.autoload_paths = []#['spec/support/dummy_app']
    config.time_zone = 'Eastern Time (US & Canada)'
    config.encoding = 'utf-8'
    config.eager_load = false
  end
end
Rails.application.initialize!(__dir__)

database_config = SpecDatabase.setup_database
ActiveRecord::Base.establish_connection database_config

require_relative '../app/models/models'
require_relative '../db/schema'

# load rake tasks
Dir[File.join(__dir__, '..', 'tasks', '*.rake')].each {|f| load f}
