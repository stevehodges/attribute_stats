require 'attribute-stats'
namespace :'attribute-stats' do
	desc "Generate migration file to remove unused attributes (and optionally those using default values) [options CONSIDER_DEFAULTS_UNUSED: false, VERBOSE: false]"
	task :migration, [:consider_defaults_unused,:verbose] => :environment do |task, args|
		args.with_defaults(consider_defaults_unused: 'false', verbose: 'true')
    options = {
      consider_defaults_unused: args[:consider_defaults_unused].downcase != 'false',
                       verbose: args[:verbose].downcase != 'false',
                        source: :cli }
    migration_file_path = AttributeStats::StatsGenerator.new(options).generate_migration
    return unless verbose
    puts "Generated migration at #{migration_file_path}"
	end
end
