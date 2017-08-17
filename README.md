## Sensu-Plugins-postgres

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-postgres.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-postgres)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-postgres.svg)](http://badge.fury.io/rb/sensu-plugins-postgres)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postgres/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postgres)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postgres/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postgres)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-postgres.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-postgres)

## Functionality

## Files
 * bin/check-postgres-alive.rb
 * bin/check-postgres-connections.rb
 * bin/metric-postgres-dbsize.rb
 * bin/metric-postgres-statsbgwriter.rb
 * bin/metric-postgres-statstable.rb
 * bin/check-postgres-replication.rb
 * bin/metric-postgres-graphite.rb
 * bin/metric-postgres-statsdb.rb
 * bin/metric-postgres-connections.rb
 * bin/metric-postgres-locks.rb
 * bin/metric-postgres-statsio.rb
 * bin/check-postgres-query.rb
 * bin/metrics-postgres-query.rb

## Usage

Use `--help` to see command arguments.

### Sample usage

#### Check if PostgreSQL is alive
```
$ check-postgres-alive.rb -d template1 -f /var/lib/postgresql/.pgpass
CheckPostgres OK: Server version: {"version"=>"PostgreSQL 9.6.3 on x86_64-pc-linux-gnu, compiled by gcc (Debian 4.9.2-10) 4.9.2, 64-bit"}
```

### Check replication status
```
$ check-postgres-replication.rb -m psql1.local -s psql2.local -d template1 -w 5 -c 10
CheckPostgresReplicationStatus OK: replication delayed by 0.0MB :: master:B0/B4031000 slave:B0/B4031000 m_segbytes:16777216
```

### Check number of connections
```
$ export PGPASSWORD=this-is-secret-password
$ check-postgres-connections.rb -a -w 80 -c 90 -d template1 -u sensu
CheckPostgresConnections OK: PostgreSQL connections under threshold: 17%, 174 out of 997 connections
```

### Default values

| Argument       | Env variable | Value     |
|----------------|--------------|-----------|
| -f, --pgpass   | PGPASSFILE   | ~/.pgpass |
| -h, --hostname | PGHOST       | localhost |
| -P, --port     | PGPORT       | 5432      |
| -d, --database | PGDATABASE   | postgres  |
| -u, --user     | PGUSER       | postgres  |
| -p, --password | PGPASSWORD   |           |

Options precedence is following:
1. command line arguments
1. pgpass file
1. env variables
1. defaults

### Pgpass file

When file `~/.pgpass` is found it is used by default. You can also use `-f, --pgpass` command line argument or set `PGPASSFILE` env variable.

File format is:

```
hostname:port:database:username:password
```

Only first line is used. If database is set to `*` it is ommited.

You can ovveride `pgpass` values with command line arguments, e.g. `-h` for hostname.

## Installation

```
gem install sensu-plugins-postgres
```

## Centos installation

```
yum -y install gcc ruby-devel rubygems  postgresql-devel
sensu-install -p sensu-plugins-postgres

```

See [Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html) for details.

### Known issues

When using Sensu with `EMBEDDED_RUBY=true` and installing Postgres checks with `/usr/bin/sensu-install -p sensu-plugins-postgres` you might get following error:

```
ERROR:  Error installing sensu-plugins-postgres:
	ERROR: Failed to build gem native extension.
[...]
checking for PQconnectdb() in -lpq... no
checking for PQconnectdb() in -llibpq... no
checking for PQconnectdb() in -lms/libpq... no
Can't find the PostgreSQL client library (libpq)
*** extconf.rb failed ***
```

The reason is that **libssl** library which comes with Sensu is incompatible with **libpq** library installed on your system. There is no easy way to fix it. You might want to install sensu-plugins-postgres globally with `gem install sensu-plugins-postgres`.

Checks are in `/usr/local/bin` directory.

## Notes
