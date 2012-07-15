require 'attribute-stats'
namespace :db do
	namespace :stats do
		desc "Usage statistics for all attributes [options CONSIDER_DEFAULTS_UNUSED: false, FORMAT: json, tabular, VERBOSE: false]"
		task :attribute_usage, [:consider_defaults_unused,:format,:verbose] => :environment do |task, args|
			args.with_defaults(consider_defaults_unused: 'false', format: 'tabular', verbose: 'true')
      options = {
        consider_defaults_unused: args[:consider_defaults_unused].downcase != 'false',
                       formatter: args[:format],
                         verbose: args[:verbose].downcase != 'false',
                          source: :cli }
      AttributeStats::StatsGenerator.new(options).attribute_usage
		end
	end
end
