module AttributeStats
  class TableData
    attr_reader :count, :table_name, :attributes, :name, :last_updated, :model
    def initialize(model)
      @model        = model
      @name         = model.name
      @table_name   = model.table_name
      @attributes   = []
      @dormant      = false
      @count        = 0
      @column_names = model.columns.map(&:name)
    end

    def column_names
      @column_names
    end

    def make_dormant(last_updated)
      @dormant = true
      last_updated  = last_updated.to_datetime unless last_updated.nil?
      @last_updated = last_updated
    end

    def dormant?
      @dormant
    end

    def set_count(total_record_count)
      @count = total_record_count
    end

    def attribute_for(attribute_name)
      unless attribute = attributes.detect{|a| a.name == attribute_name }
        attribute = AttributeInfo.new(attribute_name)
        @attributes << attribute
      end
      attribute
    end

    def unused_attribute_info
      @unused_attribute_info ||= begin
        attrs = []
        @attributes.each do |attribute|
          attrs << attribute if attribute.empty?
        end
        attrs
      end
    end

    def unused_attributes
      @unused_attributes ||= unused_attribute_info.map(&:name)
    end
  end
end