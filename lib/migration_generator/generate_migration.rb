module AttributeStats
  class GenerateMigration
    def initialize(table_info: [], options: {})
      @table_info, @options = table_info, options
    end

    def output_migration
      return nil if migration_template.blank?
      File.open(migration_file_path, 'w') do |f|
        f.write(migration_template)
      end
      migration_file_path
    end

    private

    def migration_file_path
      "#{base_path}/#{next_migration_number}_remove_unused_attributes_#{migration_class_suffix}.rb"
    end

    def migration_template
      MigrationTemplateContents.new(
        table_info: @table_info, migration_class_suffix: migration_class_suffix
      ).content
    end

    def migration_class_suffix
      @migration_class_suffix ||= find_migration_class_suffix
    end

    def find_migration_class_suffix
      existing_migration_suffix = Dir.glob("#{base_path}/[0-9]*_remove_unused_attributes_*.rb").map do |fn|
        next unless match = fn.match(/(\d+).rb/)
        match[1].to_i
      end.compact.max
      existing_migration_suffix ||= 0
      existing_migration_suffix + 1
    end

    # The following methods are extracted from Railties
    # railties/lib/rails/generators/migration.rb
    def next_migration_number
      next_migration_number = current_migration_number + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def current_migration_number
      existing_migration_lookup.collect do |file|
        File.basename(file).split("_").first.to_i
      end.max.to_i
    end

    def existing_migration_lookup
      Dir.glob("#{base_path}/[0-9]*_*.rb")
    end
    # End Railties methods

    def base_path
      Rails.root.join('db', 'migrate')
    end
  end
end
