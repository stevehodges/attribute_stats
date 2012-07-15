Attribute Stats gives you insight into which persisted attributes are actually used in your Rails models. Whether you're joining an existing project or have been using it for years, get a quick look at the landscape of the database.

It helps you find smells in your project:
- **Attributes are completely empty in the database** (smells like a potentially unused attribute)
- **Tables which haven't been updated for X years** (smells like a potentially unused or legacy model)
- **Attributes used by very few objects in your table** (smells like something that maybe shouldn't be an attribute)
- **Attributes which are all set to the default value** (if they're all default, is this really being used?)

## Installation

[![Gem Version](https://badge.fury.io/rb/attribute-stats.svg)](https://badge.fury.io/rb/attribute-stats)

Add `gem 'attribute-stats'` to your Gemfile, bundle, and follow the Usage instructions below.

## Usage

### Programmatic

You can use `AttributeStats` from within Rails (or a Rails console):

    irb:1> stats = AttributeStats::StatsGenerator.new()
    irb:2> stats.attribute_usage
    => {...} # a list of your attributes and what % of records have a value set
    irb:3> stats.unused_attributes
    => {...} # a list of your attributes which have no value set in the database
    irb:4> stats.dormant_tables
    => [...] # a list of your tables which have not been updated in awhile
    irb:5> stats.migration
    => # sample migration up/down to remove your unused attributes
    irb:6> stats.set_formatter :json
    irb:7> stats.migration # returns json instead of a hash

### Rake Tasks

Rake tasks are available once you've installed the gem in your Gemfile and bundled:

* rake db:stats:dormant_tables
* rake db:stats:attribute_usage
* rake db:stats:unused_attributes
* rake attribute-stats:generate_migration

Each allows you to change the output to JSON if you'd like to pipe it into another application.

---

#### rake db:stats:unused_attributes
Lists all attributes which are unused (have a nil or empty value).

**Argument Options:**
1. consider_defaults_unused: true or false (default: false). This option considers attributes set to the databse default value to be unused.
2. format: tabular, json  (default: tabular)
3. verbose: true, false (default: true)

i.e. `rake db:stats:unused_attributes[true,json,false]`

---

#### rake db:stats:attribute_usage
Lists usage statistics for all attributes (count and percent which are unused). Note: this does a full scan of your tables, so it will be slow for tables with a lot of data.

**Argument Options:**
1. consider_defaults_unused: true or false (default: false). This option considers attributes set to the databse default value to be unused.
2. format: tabular, json  (default: tabular)
3. verbose: true, false (default: true)

i.e. `rake db:stats:attribute_usage[true,json,false]`

---

#### rake db:stats:dormant_tables
Lists tables which have not been updated in the past X months (default is 3.months.ago)

**Argument Options:**
1. date_expression: A Rails date expression, i.e. '3.months.ago'. Tables with updated_at values after that date are not considered dormant.
2. format: tabular, json  (default: tabular)
3. verbose: true, false (default: true)

i.e. `rake db:stats:dormant_tables['1.year.ago',json,false]`

---

#### rake attribute-stats:migration
Generates a sample migration syntax to remove all unused attributes. (This is just output, not saved to disk. See the TODO below.)

**Argument Options:**
1. consider_defaults_unused: true or false (default: false). This option considers attributes set to the databse default value to be unused.

*TODO: actually save that generated file to the db/migrate path of the host Rails app.*

## Caveats

The gem does not support:

1. Detection of unset encrypted attributes. `attribute-stats` works by searching for empty values using SQL. If you are encrypting data before storing it in the database, a value of `nil` might have a value in the database which, decrypted, equals `nil`.
1. Custom table names. If you are defining a model called House, and configure the model to use the table 'domiciles' instead of 'houses', `attribute-stats` skips analysis of the table. *(TODO: fix)*
1. Tables not associated with a model. If your database has tables which do not correspond with a model (see point #2), `attribute-stats` skips analysis of that table. *(TODO: fix)*

## Compatability

The gem is tested and works with Rails version 4.2 through 5.2, with `mysql2`, `sqlite3`, and `postgresql` database adapters. You can view all tested dependency sets in [Appraisals](Appraisals)

*Due to changes in ActiveRecord between 4.1 and 4.2, the gem breaks in versions below 4.2. In a future version of `attribute-stats`, I intend to add support to previous versions of Rails (at least back to 4.0).*

## Testing the gem

To test the gem against the current version of Rails (in [Gemfile.lock](Gemfile.lock)) and sqlite:

1. `bundle install`
2. `bundle exec rspec`

Or, you can run tests for all supported Rails versions and supported databases:

1. Add your database config at `spec/database.yml` pointing to empty local mysql and postgres test databases (see [database.yml.sample](spec/database.yml.sample))
1. `gem install appraisal`
1. `bundle exec appraisal install` *(this Generates gemfiles for all permutations of our dependencies, so you'll see lots of bundler output))*
1. `bundle exec appraisal rspec`. *(This runs rspec for each dependency permutation. If one fails, appraisal exits immediately and does not test permutations it hasn't gotten to yet. Tests are not considered passing until all 12 permutations are passing)*

If you only want to test a certain dependency set, such as Rails 5.2 for MySQL: `bundle exec appraisals rails-5-2-mysql`. In this case, you would *not* need to configure postgresql in your database.yml, nor have postgres running on your machine.

You can view all available dependency sets in [Appraisals](Appraisals)