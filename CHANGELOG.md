# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md).

## [Unreleased]
### Added
- asset for generic debian build (including ubuntu) (@VeselaHouba)

## [4.2.0] - 2020-11-29
### Added
- new `bin/metric-postgres-relation-size.rb` find largest tables (@phumpal)

## [4.1.0] - 2020-06-04
### Added
- new `metric-postgres-vaccum.rb` metric gathering script for postgres vacuum process (@phumpal)

## [4.0.2] - 2020-06-02
- Fixed `# frozen_string_literal: true` does not play nicely with mixlib-cli.

## [4.0.1] - 2020-04-20
### Fixed
- Fixing asset build directives.

## [4.0.0] - 2020-01-09

### Breaking Changes
- Update `sensu-plugin` dependency from `~> 1.2` to `~> 4.0` you can read the changelog entries for [4.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#400---2018-02-17), [3.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#300---2018-12-04), and [2.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#v200---2017-03-29)
- `check-postgres-replication.rb`: both `--slave-host` and `master-host` arguments are now required flags where previously they had localhost defaults (@phumpal)

### Fixed
- `check-postgres-replication.rb`: fix condition where connection timeout is considered a boolean rather than an integer value (@majormoses) (@phumpal) (@VeselaHouba)
- `check-postgres-replication.rb`: critical if the master and slave are same (@phumpal)

### Added
- `check-postgres-query.rb`: Add `-r`, `--regex-pattern` to match query result against (@jindraj)

### Changes
- Updated development dependency to bundler ~> 2.1
- Updated development dependency to rake ~> 13.0
- Updated development dependency to test-kitchen ~> 1.25.0
- Updated runtime dependency to 'pg' '1.2.1' from 1.1
- Updated runtime dependency 'dentaku' '3.3.4' from 2.04

## [3.0.0] - 2019-11-20
### Breaking Changes
- Removed ruby < 2.4 since these Rubies are EOL (@phumpal)

## [2.4.0] - 2019-10-04
### Added
- Support comments in pgpass file. Keeps previous behavior and adds support for ignoring leading comments (@phumpal)

## [2.3.2] - 2019-03-12
### Fixed
- Support for PostgreSQL v10+ replication function names fixed in `bin/metric-postgres-graphite.rb` (@jfineberg)

## [2.3.1] - 2018-12-16
### Fixed
- metric-postgres-statsdb.rb: Change `Array` method from `append` to `push` to maintain compatibility w/ non-EOL Rubies (@phumpal)

## [2.3.0] - 2018-12-08
### Added
- metric-postgres-statsdb.rb: Add --all-databases option. (@cyrilgdn)

## [2.2.2] - 2018-10-27
### Fixed
- Remove unexplicit dependency on ActiveSupport (@multani)

## [2.2.1] - 2018-10-16
### Security
- updated yard dependency to `~> 0.9.11` per: https://nvd.nist.gov/vuln/detail/CVE-2017-17042 (@majormoses)

## [2.2.0] - 2018-10-16
### Added
- metric-postgres-statsbgwriter.rb: additional metrics (@phumpal)
- metric-postgres-statsdb.rb additional metrics (@phumpal)

## [2.1.0] - 2018-10-16
### Added
- Moves check_vsn and compute_lag to library method (@phumpal)

## [2.0.0] - 2018-10-15
### Breaking Changes
- Remove unsupported Rubies: `< 2.3.0` (@phumpal)

## [1.4.6] - 2018-05-03
### Fixed
- version number check for build strings such as `10.3 (Ubuntu 10.3-1.pgdg16.04+1)` (@jfineberg)

### Added
- tests for connecting with a pgpass file (@majormoses)

## [1.4.5] - 2018-02-15
### Fixed
- metric-postgres-graphite.rb: use the custom defined port when connecting to slave (@henkjan)

### Added
- basic skel for integration testing with postgres (@majormoses)
- added test for `./bin/check-postgres-alive.rb`

## [1.4.4] - 2017-11-08
### Fixed
- check-postgres-replication.rb: fix 9.x compatibility

## [1.4.3] - 2017-11-06
### Fixed
- check-postgres-replication.rb: maintains backwards compatibility with <= 9.6 and adds compatibility for >= 10

## [1.4.2] - 2017-09-27
### Fixed
- metric-postgres-locks.rb: Fix lock count collection (@madboxkr)

## [1.4.1] - 2017-09-26
### Fixed
- metrics-postgres-query.rb: Add a nil check to avoid failure when the query result is empty (@eheydrick)
- PR template spelling (@majormoses)

### Changed
- updated CHANGELOG guidelines location (@majormoses)

## [1.4.0] - 2017-08-04
### Added
- all checks now support using the pgpass file and is backwards compatible with the previous versions (@ahes)

## [1.3.0] - 2017-07-25
### Fixed
- Take into account reserved superuser connections in check-postgres-connections.rb (@Evesy)

### Added
- Ruby 2.4.1 testing

## [1.2.0] - 2017-07-12
### Added
- metric-postgres-statsdb.rb: Adds new metric `numbackends`. (@phumpal)

## [1.1.2] - 2017-06-02
### Fixed
- check-postgresq-replication.rb: Adds missing option for custom port.

## [1.1.1] - 2017-04-24
### Fixed
- metrics-postgres-query.rb: Restored default value to only return first value in query. (@Micasou)

## [1.1.0] - 2017-04-20
### Added
- metrics-postgres-query.rb: Add option to return multi row queries. (@Micasou)

### Fixed
- check-postgres-alive.rb: Fix connections using a custom port (#25 via @mickfeech)
- check-postgres-connections.rb: Fix connections using a custom port (#25)
- check-postgres-query.rb: Fix connections using a custom port (#25)
- check-postgres-replication.rb: Fix connections using a custom port (#25)
- metrics-postgres-connections.rb: Fix connections using a custom port (#25)
- metrics-postgres-dbsize.rb: Fix connections using a custom port (#25)
- metrics-postgres-graphite.rb: Fix connections using a custom port (#25)
- metrics-postgres-graphite.rb: Fix connections using password (@teadur)
- metrics-postgres-locks.rb: Fix connections using a custom port (#25)
- metrics-postgres-statsgbwriter.rb: Fix connections using a custom port (#25)
- metrics-postgres-statsdb.rb: Fix connections using a custom port (#25)
- metrics-postgres-statsio.rb: Fix connections using a custom port (#25)
- metrics-postgres-statstable.rb: Fix connections using a custom port (#25)
- metrics-postgres-query.rb: Fix connections using a custom port (#25)
- check-postgres-connections.rb: Fix logic to check critical first then warning (#24 via @nevins-b)

## [1.0.1] - 2017-01-04
### Fixed
- metrics-postgres-query.rb: Fix `count_tuples` option (#23) (@eheydrick)

## [1.0.0] - 2016-12-27
### Fixed
- metric-postgres-connections: Handle postgres version 9.6 and above.

### Removed
- Ruby 1.9.3 and 2.0.0 support

### Added
- Ruby 2.3.0 support
- Update all the scripts to add an optional timeout setting.

## [0.1.1] - 2016-03-24
### Added
- metric-postgres-connections: Add new metric `total`

### Fixed
- metric-postgres-connections: Correctly evaluate and collect metrics for active connections and active connections waiting on backend locks

## [0.1.0] - 2016-03-09
### Added
- Add new plugin `check-postgres-connections` that checks the number of connections to a DB

## [0.0.7] - 2015-12-10
### Changed
- fixed [ -S | -ssl ] short option

## [0.0.6] - 2015-10-08
### Changed
- standardized headers

### Added
- added plugins for querying postgres

## [0.0.5] - 2015-10-06
### Changed
- updated pg gem to 0.18.3
- Added port cli option to postgres-graphite.rb.

## [0.0.4] - 2015-08-04
### Changed
- general cleanup, no code changes

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - 2015-06-03
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-04-30
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/4.2.0...HEAD
[4.2.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/4.1.0...4.2.0
[4.1.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/4.0.2...4.1.0
[4.0.2]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/4.0.1...4.0.2
[4.0.1]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/4.0.0...4.0.1
[4.0.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/3.0.0...4.0.0
[3.0.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.4.0...3.0.0
[2.4.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.3.2...2.4.0
[2.3.2]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.3.1...2.3.2
[2.3.1]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.2.2...2.3.0
[2.2.2]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.2.1...2.2.2
[2.2.1]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.6...2.0.0
[1.4.6]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.5...1.4.6
[1.4.5]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.4...1.4.5
[1.4.4]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.3...1.4.4
[1.4.3]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.2...1.4.3
[1.4.2]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.1...1.4.2
[1.4.1]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.0...1.4.1
[1.4.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.1.2...1.2.0
[1.1.2]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.1.1...1.0.0
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.0.7...0.1.0
[0.0.7]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.0.6...0.0.7
[0.0.6]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/0.0.1...0.0.2
