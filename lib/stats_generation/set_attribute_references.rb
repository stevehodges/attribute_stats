require_relative 'terminal'
module AttributeStats
  class SetAttributeReferences
    include Terminal
    attr_reader :table_info

    def initialize(table_info: [], options: {})
      @table_info, @options = table_info, options
    end

    def execute
      @executed ||= begin
        lookup_and_set_attribute_counts
        true
      end
    end

    private

    def lookup_and_set_attribute_counts
      @table_info.each_with_index do |t,index|
        @table_count = index
        @current_table = t
        fetch_table_stats
      end
      erase_line if @options[:verbose]
      true
    end

    private

    def fetch_table_stats
      print("Finding Code References #{in_color(@current_table.name,@table_count)} ") if @options[:verbose]
      set_reference_counts
      erase_line if @options[:verbose]
    end

    def set_reference_counts
      @current_table.unused_attribute_info.each do |attribute_info|
        count = set_attribute_reference_count(attribute_info)
        next unless @options[:verbose]
        print count.zero? ? green('✓') : red('x')
      end
    end

    def set_attribute_reference_count(attribute_info)
      files = `grep -rcE "#{regexes(attribute_info).join('|')}" --exclude-dir={#{regex_exclude_paths.join(',')}} #{regex_target_paths.join(' ')}`
      attribute_total = 0
      files.scan(/(.*):(\d+)(?:\n|\z)/).each do |matches|
        next if matches[0].nil?
        filename, count = matches[0], matches[1].to_i
        next if count == 0
        attribute_total += count
        attribute_info.set_reference section(filename), count
      end
      attribute_total
    end

    def regexes(attribute_info)
      [
        "\\\"#{attribute_info.name}\\\"",                # "my_attribute_name"
        "'#{attribute_info.name}'",                      # 'my_attribute_name'
        "\\:#{attribute_info.name}[^A-Za-z_]?",           # :my_attribute_name
        "\\.#{attribute_info.name}[^A-Za-z_]?",           # .my_attribute_name
        # "[^A-Za-z_]#{attribute_info.name}[^A-Za-z_]",  #  my_attribute_name (standalone word)
      ]
    end

    def regex_target_paths
      directories = @options[:include_directories] || %w(app lib config spec)
      if regex_base_path
        directories.map do |directory|
          File.join regex_base_path, directory
        end
      else
        directories
      end
    end

    def regex_exclude_paths
      directories = @options[:exclude_directories] || %w(app/assets db public)
      if regex_base_path
        directories.map do |directory|
          File.join regex_base_path, directory
        end
      else
        directories
      end
    end

    def section(filename)
      if filename =~ /\A#{regex_base_path}\/spec\//
        'spec'
      elsif filename =~ /\A#{regex_base_path}\/app\/views\//
        'views'
      else
        'app'
      end
    end

    def regex_base_path
      @options[:rails_root]
    end
  end
end
