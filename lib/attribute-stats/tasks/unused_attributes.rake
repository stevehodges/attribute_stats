require 'attribute-stats'
namespace :db do
  namespace :stats do
    desc "View attributes with no data in the database (and optionally those using default values) [options CONSIDER_DEFAULTS_UNUSED: false, FORMAT: json, tabular, VERBOSE: false]"
    task :unused_attributes, [:consider_defaults_unused,:format,:verbose] => :environment do |task, args|
      args.with_defaults(consider_defaults_unused: 'false', format: 'tabular', verbose: 'true')
      options = {
        consider_defaults_unused: args[:consider_defaults_unused].downcase != 'false',
                       formatter: args[:format],
                         verbose: args[:verbose].downcase != 'false',
                          source: :cli }
      AttributeStats::StatsGenerator.new(options).unused_attributes
    end
  end
end
