#https://www.eliotsykes.com/test-rails-rake-tasks-with-rspec
require 'rake'
require 'active_support'
module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    # Make the Rake task available as `task` in your examples:
    subject(:task) { Rake::Task[task_name] }
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/tasks/}) do |metadata|
    metadata[:type] = :task
  end
  config.include TaskExampleGroup, type: :task
end