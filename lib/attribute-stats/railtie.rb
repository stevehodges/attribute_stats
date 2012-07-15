require 'rails'

module AttributeStats
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[File.join(__dir__, 'tasks/*.rake')].each { |f| load f }
    end
  end
end