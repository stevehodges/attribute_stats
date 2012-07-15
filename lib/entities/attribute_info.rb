module AttributeStats
  class AttributeInfo
    attr_reader :count, :usage_percent, :name, :empty

    def initialize(attribute_name)
      @name = attribute_name
    end

    def set_usage(record_count, table_total_record_count)
      @count = record_count
      @usage_percent = (record_count / table_total_record_count.to_f).round(5)
      @empty = record_count == 0
    end

    def set_emptyness(is_empty)
      @empty = is_empty
    end

    def empty?
      @empty
    end
  end
end