require 'attribute-stats'
namespace :'attribute-stats' do
	desc "Generate sample migration to remove unused attributes (and optionally those using default values) [options CONSIDER_DEFAULTS_UNUSED: false, FORMAT: json, tabular, VERBOSE: false]"
	task :migration, [:consider_defaults_unused,:format,:verbose] => :environment do |task, args|
		args.with_defaults(consider_defaults_unused: 'false', format: 'tabular', verbose: 'true')
    options = {
      consider_defaults_unused: args[:consider_defaults_unused].downcase != 'false',
                     formatter: args[:format],
                       verbose: args[:verbose].downcase != 'false',
                        source: :cli }
    AttributeStats::StatsGenerator.new(options).migration
	end
end
