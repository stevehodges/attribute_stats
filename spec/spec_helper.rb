$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'support/tasks'
require 'support/migration_helper_methods'
require 'support/dummy_app/application'
require 'attribute-stats'
include MigrationHelperMethods

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


