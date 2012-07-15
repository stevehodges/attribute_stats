module AttributeStats
  class StatsGenerator
    attr_reader :options, :table_info, :migration

    DEFAULT_OPTIONS = {
      consider_defaults_unused: true,
                      defaults: false,
                     formatter: :hash,
                        source: :code,
             dormant_table_age: '3.months.ago',
                       verbose: false }

    def initialize(opts={})
      @options = DEFAULT_OPTIONS.merge(opts)
    end

    def attribute_usage
      fetch_attribute_usage
      output formatter.output_all_attributes
    end

    def dormant_tables
      fetch_dormant_tables
      output formatter.output_dormant_tables
    end

    def unused_attributes
      fetch_empty_attributes
      output formatter.output_unused_attributes
    end

    def migration
      generate_migration
      output formatter.output_migration
    end

    def set_formatter(formatter_type)
      formatter_was = options[:formatter]
      case formatter_type.to_s.downcase
      when 'json'
        options[:formatter] = :json
      when 'tabular'
        options[:formatter] = :tabular
      when 'hash'
        options[:formatter] = :hash
      end
      @formatter = nil unless options[:formatter] == formatter_was
      options[:formatter]
    end

    def inspect
      "StatsGenerator(results: #{table_info.to_s[0..200]}, options: #{options})"
    end

    private

    def formatter
      @formatter ||= begin
        output = case options[:formatter].to_s.downcase
        when 'json'
          JSONFormatter
        when 'hash'
          HashFormatter
        else
          TabularFormatter
        end.new(options: options, table_info: table_info, migration: @migration)
      end
    end

    def output(value)
      return if value.nil?
      if options[:source] == :cli || value.is_a?(String)
        puts value
      else
        value
      end
    end

    def fetch_attribute_usage
      @fetch_attribute_usage ||= begin
        initialize_tables
        attribute_stats_setter.set_counts
        true
      end
    end

    def fetch_empty_attributes
      @fetch_empty_attributes ||= begin
        initialize_tables
        attribute_stats_setter.set_empty
        true
      end
    end

    def attribute_stats_setter
      @attribute_stats_setter ||= SetAttributeStats.new(table_info: table_info, options: options)
    end

    def fetch_dormant_tables
      @fetched_dormant_tables ||= begin
        initialize_tables
        SetDormantTables.new(table_info: table_info, options: options).call
        true
      end
    end

    def generate_migration
      fetch_empty_attributes
      @migration ||= GenerateMigration.new(table_info: table_info, options: options)
    end

    def initialize_tables
      return unless table_info.nil?
      @table_info = []
      tables.sort.each{|table| setup_table_and_model(table) }
    end

    def setup_table_and_model(table)
      @table_info << TableData.new(table.classify.constantize)
    rescue NameError => ex
    end

    def tables
      ActiveRecord::Base.connection.data_sources
    end
  end
end