module AttributeStats
  class MigrationTemplateContents
    def initialize(table_info: [], migration_class_suffix: nil)
      @table_info, @migration_class_suffix = table_info, migration_class_suffix
      @migration_buffer = ''
      @table_info.each do |table_info|
        add_migrations_for_table_to_buffer(table_info)
      end
    end

    def content
    	return nil if @migration_buffer.blank?
      output = "class RemoveUnusedAttributes#{@migration_class_suffix} < ActiveRecord::Migration"
      output << "[#{Rails::VERSION::STRING}]" if Rails::VERSION::MAJOR >= 5
      output << "\n#{warning_to_width}"
      output << <<-OUTPUT
  def change
#{@migration_buffer}
  end
end
      OUTPUT
      output
    end

    private

    # This is a modified version of the ActiveRecord::SchemaDumper#table method.
    # Unfortunately, Rails generators cannot accept multiple tables in a single RemoveXXXFromXXX
    # migration (maybe I should submit a PR to Rails?)
    # ActiveRecord::SchemaDumper cannot be reused for this case, so I had to extract it.
    def add_migrations_for_table_to_buffer(table_info)
      @connection ||= ActiveRecord::Base.connection
      @types      ||= @connection.native_database_types

      column_specs = []
      @connection.columns(table_info.table_name).each do |column|
        next unless column.name.to_s.in? table_info.unused_attributes
        column_specs << column_spec_for(column)
      end

      quoted_table_name  = "\"#{table_info.table_name}\""
      column_specs.each do |colspec|
        down_syntax = [quoted_table_name, colspec[:name], ":#{colspec[:type]}", colspec[:options].presence].compact.join(', ')
        @migration_buffer << "    #  remove_column #{down_syntax}\n"
      end
    end

    def warning_to_width(target_width=78)
      line_start = "  # "
      output = ""
      warning.split("\n").each do |line|
        line_buffer = "\n#{line_start}"
        line.split(/ +/).each do |word|
          if word.length + line_buffer.length > target_width
            output << line_buffer
            line_buffer = "\n#{line_start}"
          end
          line_buffer << "#{word} "
        end
        output << line_buffer+"\n#{line_start}"
      end
      output + "\n"
    end

    def column_spec_for(column)
      # Rails 5.2
      # SchemaDumper           returns an array like: [:text, {:limit=>"255"}]
      # Rails 5.1
      # connection.column_spec returns an array like: [:text, {:limit=>"255"}]
      # prior to Rails 5.1
      # connection.column_spec returns a  hash  like: {:name=>"\"line_2\"", :type=>"string", :limit=>"limit: 255"}
      if    Rails::VERSION::MAJOR >= 5 && Rails::VERSION::MINOR == 2
        column_spec_for_5_2(column)
      elsif Rails::VERSION::MAJOR >= 5 && Rails::VERSION::MINOR >= 1
        column_spec_for_5_1(column)
      elsif Rails::VERSION::MAJOR >= 5 && Rails::VERSION::MINOR == 0
        column_spec_for_5_0(column)
      else
        column_spec_for_4(column)
      end
    end

    def column_spec_for_5_2(column)
      # Unfortunately Rails has moved this logic from Connection to a private method on SchemaDumper...
      # Rails really doesn't want people using this stuff!
      colspec = ActiveRecord::ConnectionAdapters::SchemaDumper
                  .send(:new, @connection, {})
                  .send(:column_spec, column)
      spec = {
        name: @connection.quote_column_name(column.name),
        type: colspec[0]
      }
      spec[:options] = colspec[1].map{|k,v| "#{k}: #{v}"}.join(', ') if colspec[1].is_a?(Hash)
      spec
    end


    def column_spec_for_5_1(column)
      colspec = @connection.column_spec(column)
      spec = {
        name: @connection.quote_column_name(column.name),
        type: colspec[0],
      }
      spec[:options] = colspec[1].map{|k,v| "#{k}: #{v}"}.join(', ') if colspec[1].is_a?(Hash)
      spec
    end

    def column_spec_for_5_0(column)
      colspec = @connection.column_spec(column)
      colspec[:options] = colspec.except(:type, :name).values.join(', ')
      colspec
    end

    def column_spec_for_4(column)
      colspec = @connection.column_spec(column, @types)
      colspec[:options] = colspec.except(:type, :name).values.join(', ')
      colspec
    end

    def warning
      <<-WARNING
REVIEW THIS MIGRATION CAREFULLY!
This migration code was generated by analyzing database columns which are empty at the time the script was executed.
IT IS YOUR RESPONSIBILITY to verify that these attributes are indeed unused in your application before running this migration. For your protection, the generated commands are COMMENTED OUT.
If you were to uncomment the below commands and migrate your database, it is extremely likely that your application will break due to references to the removed attributes in your application code.
WARNING
    end
	end
end