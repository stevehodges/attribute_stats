$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'support/tasks'
require 'support/migration_helper_methods'
require 'support/table_info_methods'
require 'support/dummy_app/config/application'
require 'attribute-stats'
include MigrationHelperMethods

def rails_app_path
  File.join(__dir__,'support','dummy_app')
end

# prevent puts/print from outputting when testing rake tasks
RSpec.configure do |c|

  c.around do |example|
    begin
      original_stdout, original_stderr = $stdout.clone, $stderr.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      example.run
    ensure
      $stdout.reopen original_stdout
      $stderr.reopen original_stderr
    end
  end
end
