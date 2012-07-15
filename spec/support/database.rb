class SpecDatabase
  class << self
    def setup_database
      @@database_config ||= begin
        case defined_appraisal_db
        when 'mysql'
          local_database_config 'mysql'
        when 'postgresql'
          local_database_config 'postgresql'
        else # This allows us to run rspec with or without appraisals
          { adapter: 'sqlite3', database: ':memory:' }
        end
      end
    end

    private

    def new
    end

    def defined_appraisal_db
      result = ENV['BUNDLE_GEMFILE'].to_s.match(/_([^_]*)\.gemfile/)
      result ? result[1] : nil
    end

    def local_database_config(db)
      path = File.join(__dir__, '..', 'database.yml')
      raise("No database config found. Define it at #{path}.") unless File.exist?(path)
      config = YAML.load(File.read(path))
      if config[db]
        return config[db]
      else
        raise("No database config found for #{db}. Define a configuration with key #{db} in database.yml")
      end
    end
  end
end