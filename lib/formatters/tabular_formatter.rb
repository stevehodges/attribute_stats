require 'hirb'

module AttributeStats
  class TabularFormatter

    def initialize(options: {}, table_info: {}, migration: nil)
      @options, @table_info, @migration = options, table_info, migration
      @buffer = ''
    end

    def output_all_attributes
      attribute_results = []
      @table_info.each do |table_info|
        table_info.attributes.sort_by(&:usage_percent).each do |attribute|
          attribute_results << {
                    model: table_info.name,
                set_count: attribute.count,
              set_percent: (attribute.usage_percent * 100).round(1).to_s.rjust(5),
           attribute_name: attribute.name
          }
        end
      end
      if attribute_results.empty?
        puts "No attributes found"
      else
        print_table attribute_results, title: 'Attributes Utilization'
      end
      @buffer
    end

    def output_dormant_tables
      output = []
      @table_info.each do |table_info|
        date = table_info.last_updated
        output << {
                 model: table_info.name,
          last_updated: date.nil? ? 'Never Updated' : table_info.last_updated.to_date.to_s(:long)
        } if table_info.dormant?
      end
      if output.empty?
        puts "No dormant tables"
      else
        print_table output, title: ['Dormant Tables', "No updated_ats after #{@options[:dormant_table_age].to_date.to_s(:long)}"]
      end
      @buffer
    end

    def output_unused_attributes
      output = []
      @table_info.each do |table_info|
        table_info.attributes.sort_by(&:name).each do |attribute|
          output << {
                     model: table_info.name,
            attribute_name: attribute.name
          } if attribute.empty?
        end
      end
      unused_values = ['Nil', 'Empty']
      unused_values << 'Default Values' if @options[:consider_defaults_unused]
      if output.empty?
        puts "No unused attributes (good for you!)"
      else
        print_table output, title: ['Unused Attributes', unused_values.join(', ')]
      end
      @buffer
    end

    private

    def puts(*values)
      @buffer << values.join("\n")
      @buffer << "\n"
    end

    def print_table_header(table_info)
      line = '-'*(table_info.name.length+4)
      puts '', line, "  #{table_info.name}  ", line
    end

    def print_section_header(text)
      line = '#'*(text.length+4)
      puts '', line, "  #{text}  ", line
    end

    def print_table(data, title: nil)
      column_names = data.first.keys
      output = Hirb::Helpers::AutoTable.render(data,
         fields: header_order(column_names),
        headers: formatted_headers(column_names))
      output_table_title(title, output) unless title.blank?
      puts output
    end

    def output_table_title(title_rows, table_output)
      header_line = table_output.split(/\n/).first
      puts '', header_line

      Array(title_rows).each do |title|
        if header_line.length > title.length+4
          puts "| #{title.center(header_line.length - 4)} |"
        else
          puts "| #{title}"
        end
      end
    end

    def header_order(column_names)
      [:model, :table_name, :attribute_name,
        :last_updated, :set_count, :set_percent] & column_names
    end

    def formatted_headers(column_names)
      column_names.inject({}) do |hash, name|
        hash[name] = name.to_s.titleize
        hash
      end
    end
  end
end