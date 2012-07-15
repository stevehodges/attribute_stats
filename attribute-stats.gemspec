# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attribute-stats/version'

Gem::Specification.new do |spec|
  spec.name          = "attribute-stats"
  spec.version       = AttributeStats::VERSION
  spec.authors       = ["Steve Hodges"]
  spec.email         = ["sjhodges@gmail.com"]

  spec.summary       = %q{Statistics about attribute usage, unused attributes, and dormant tables in Rails projects}
  spec.description   = <<-EOF
Attribute Stats gives you insight into which attributes are actually used in your Rails models. Whether you're joining an existing project or have been using it for years, get quick info.

The stats help you find smells in your project:

Attributes which have never had data set (indicates a potentially forgotten attribute); Tables which haven't been updated for X years (indicates a potentially unused or legacy model); Attributes used by very few objects in your table (is this being used? Should it be an attribute?)

It also generates sample Rails database migration code to allow you to drop the database columns.
EOF
  spec.homepage      = 'https://github.com/stevehodges/attribute_stats'
  spec.license       = 'MIT'

  spec.required_ruby_version  = ">= 2.2.0"

	spec.files         = Dir.glob("lib/**/*") + %w(rakefile.rb LICENSE README.md)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency     'rails',     '>= 4.2', '< 6'
  spec.add_runtime_dependency     'hirb',      '~> 0.7'

  spec.add_development_dependency 'appraisal', '~> 2.2'
  spec.add_development_dependency 'bundler',   '~> 1.9'
  spec.add_development_dependency 'rake',      '~> 10.0'
  spec.add_development_dependency 'rspec',     '~> 3'
  spec.add_development_dependency 'sqlite3',   '~> 1.0'
end
