require 'attribute-stats'
namespace :db do
	namespace :stats do
		desc "View tables not updated in the past months [options DATE_EXPRESSION: X.months.ago, FORMAT: json, tabular, VERBOSE: false]"
		task :dormant_tables, [:date_expression,:format,:verbose] => :environment do |task, args|
			args.with_defaults(date_expression: '3.months.ago', format: 'tabular', verbose: 'true')
      options = {
        dormant_table_age: args[:date_expression],
	              formatter: args[:format],
	                verbose: args[:verbose] != 'false',
	                 source: :cli }
      AttributeStats::StatsGenerator.new(options).dormant_tables
		end
	end
end
