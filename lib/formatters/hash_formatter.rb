module AttributeStats
  class HashFormatter

    def initialize(options: {}, table_info: {}, migration: [])
      @options, @table_info, @migration = options, table_info, migration
    end

    def output_attribute_references
      output = []
      @table_info.each do |table_info|
        table_info.attributes.each do |attribute|
          next unless attribute.empty?
          output << {
                      model: table_info.name,
                  attribute: attribute.name,
             all_references: attribute.total_references,
            code_references: attribute.references['app'],
            spec_references: attribute.references['spec'],
            view_references: attribute.references['views']
          } 
        end
      end
      output.sort!{|a,b| a[:all_references] <=> b[:all_references]}
    end

    def output_all_attributes
      output = []
      @table_info.each do |table_info|
        table_info.attributes.each do |attribute|
          output << {
                    model: table_info.name,
                attribute: attribute.name,
                    count: attribute.count,
            usage_percent: attribute.usage_percent
          }
        end
      end
      output
    end

    def output_dormant_tables
      output = []
      @table_info.each do |table_info|
        output << table_info.table_name if table_info.dormant?
      end
      output
    end

    def output_unused_attributes
      output = []
      @table_info.each do |table_info|
        table_info.attributes.sort_by(&:name).each do |attribute|
          next unless attribute.empty?
          output << {
                model: table_info.name,
            attribute: attribute.name
          } 
        end
      end
      output
    end
  end
end