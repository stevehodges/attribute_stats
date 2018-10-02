## [0.3.0] - 2018-10-02

:jack_o_lantern: Hacktoberfest 2018

### Added
- rake db:stats:unused_attribute_references outputs the number of code references to unused attributes

### Changed
- Public set_table_info methods removed from GenerateMigration & MigrationTemplateContents classes

## [0.2.0] - 2018-10-01

:jack_o_lantern: Hacktoberfest 2018

### Changed
- rake attribute-stats:generate_migration now installs an actual migration file in db/migrate. Previously, it just output sample migration file contents the user could copy/paste into db/migrate.
- Now compatible with Ruby 2.0 and later. Previously, required Ruby 2.2
