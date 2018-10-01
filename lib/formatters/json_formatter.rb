module AttributeStats
  class JSONFormatter < HashFormatter

    def output_all_attributes
      super.to_json
    end

    def output_dormant_tables
      super.to_json
    end

    def output_unused_attributes
      super.to_json
    end
  end
end