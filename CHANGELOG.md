# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]

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

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-postgres/compare/1.4.0...HEAD
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
