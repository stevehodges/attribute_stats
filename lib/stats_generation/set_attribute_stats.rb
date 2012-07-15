require_relative 'terminal'
module AttributeStats
  class SetAttributeStats
    include Terminal

    def initialize(table_info: [], options: {})
      @table_info, @options = table_info, options
    end

    def set_counts
      @query_method = :count
      set_stats
    end

    def set_empty
      @query_method = :exists?
      set_stats
    end

    def set_stats
      @table_info.each_with_index do |t,index|
        @table_count = index
        fetch_table_stats(t)
      end
      erase_line if @options[:verbose]
      true
    end

    private

    def fetch_table_stats(table)
      @current_table = table
      @current_model = table.model
      set_table_count
      print("Scanning #{in_color(table.name,@table_count)} ") if @options[:verbose]
      return if @current_table.count == 0
      set_attribute_counts
      erase_line if @options[:verbose]
    end

    def set_table_count
      @current_table.set_count(@current_model.all.count)
    end

    def set_attribute_counts
      attribs = @current_model.columns.dup
      attribs.reject!{|c| ["id","created_at","updated_at"].include? c.name } unless @options[:defaults]

      attribs.each do |column_specification|
        attribute_info = @current_table.attribute_for(column_specification.name)
        if @query_method == :count
          next if attribute_info.count
          record_count = attribute_query(column_specification).count
          empty = record_count == 0
          attribute_info.set_usage record_count, @current_table.count
        else
          next unless attribute_info.empty.nil?
          empty = !attribute_query(column_specification).exists?
          attribute_info.set_emptyness empty
        end
        next unless @options[:verbose]
        print empty ? red('E') : green('.')
      end
    end

    def attribute_query(column_specification)
      query = @current_model.where.not(column_specification.name => nil)
      query = safe_add_not_empty_query(query, column_specification)
      query = add_condition_for_default_value(query, column_specification) if @options[:consider_defaults_unused]
      query
    end

    def add_condition_for_default_value(query, attrib)
      default_value = @current_model.columns_hash[attrib.name].default
      return query if default_value.blank?
      query.where.not(attrib.name => default_value)
    end

    # In addition to normal string attributes, this allows us to query serialized columns.
    # If you serialize an attribute as an array or hash or whatever, Rails still stores empty
    # array/hashes as an empty string in the db. Using the more rails-y
    #   where.not(serialized_attribute_name => '')
    # results in a SerializationTypeMismatch error. So we construct the subquery by hand.
    def safe_add_not_empty_query(query, column_specification)
      return query unless ([:text, :string].include?(column_specification.type))
      query.where.not("#{quoted_column_name(column_specification.name)} = ''") 
    end

    def quoted_column_name(column_name)
      ActiveRecord::Base.connection.quote_column_name column_name
    end
  end
end
