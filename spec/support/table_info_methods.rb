module TableInfoMethods
  def set_table_info
    stats_generator = AttributeStats::StatsGenerator.new
    stats_generator.send(:fetch_empty_attributes)
    @table_info = stats_generator.table_info
  end
end