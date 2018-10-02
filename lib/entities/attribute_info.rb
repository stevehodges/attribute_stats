module AttributeStats
  class AttributeInfo
    attr_reader :count, :usage_percent, :name, :empty, :references

    def initialize(attribute_name)
      @name = attribute_name
      @references = Hash.new(0)
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

    def set_reference(reference_type, count)
      references[reference_type] += count
    end

    def total_references
      references.values.sum
    end
  end
end
