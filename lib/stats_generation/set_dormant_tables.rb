require_relative 'terminal'

module AttributeStats
  class SetDormantTables
    include Terminal

    def initialize(table_info: [], options: {})
      @table_info, @options = table_info, options
    end

    def call
      @table_info.each_with_index do |table_data,index|
        @table_count = index
        set_dormant_table(table_data)
      end
      erase_line if @options[:verbose]
      true
    end

    private

    def set_dormant_table(table_data)
      query_column = (['updated_at', 'created_at'] & table_data.column_names)[0]
      return if query_column.nil?
      print("Scanning #{in_color(table_data.name,@table_count)} ") if @options[:verbose]
      updated_at = table_data.model.maximum(query_column)
      table_data.make_dormant(updated_at) if updated_at.nil? || updated_at <= dormant_table_age
      erase_line if @options[:verbose]
    end

    def dormant_table_age
      return @options[:dormant_table_age] if @options[:dormant_table_age].respond_to?(:strftime)
      # Safely generate Rails duration (instead of risker eval)
      parts = @options[:dormant_table_age].split('.')
      duration_expression = parts[0].to_i.send(parts[1]).send(parts[2])
      @options[:dormant_table_age] = duration_expression
    end
  end
end
