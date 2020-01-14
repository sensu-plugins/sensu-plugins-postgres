#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   metric-postgres-locks
#
# DESCRIPTION:
#
#   This plugin collects postgres database lock metrics
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: pg
#
# USAGE:
#   ./metric-postgres-locks.rb -u db_user -p db_pass -h db_host -d db
#   ./metric-postgres-locks.rb -u db_user -p db_pass -h db_host -d 'db1,db2'
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2012 Kwarter, Inc <platforms@kwarter.com>
#   Author Gilles Devaux <gilles.devaux@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-postgres/pgpass'
require 'sensu-plugins-postgres/pgdatabases'
require 'sensu-plugin/metric/cli'
require 'pg'
require 'socket'

class PostgresStatsDBMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :pgpass,
         description: 'Pgpass file',
         short: '-f FILE',
         long: '--pgpass',
         default: ENV['PGPASSFILE'] || "#{ENV['HOME']}/.pgpass"

  option :user,
         description: 'Postgres User',
         short: '-u USER',
         long: '--user USER'

  option :password,
         description: 'Postgres Password',
         short: '-p PASS',
         long: '--password PASS'

  option :hostname,
         description: 'Hostname to login to',
         short: '-h HOST',
         long: '--hostname HOST'

  option :port,
         description: 'Database port',
         short: '-P PORT',
         long: '--port PORT'

  option :databases,
         description: 'Database names, separated by ","',
         short: '-d DB',
         long: '--db DB',
         default: nil

  option :scheme,
         description: 'Metric naming scheme, text to prepend to $queue_name.$metric',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.postgresql"

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT',
         default: nil

  include Pgpass
  include Pgdatabases

  def run
    timestamp = Time.now.to_i

    locks_per_type = Hash.new(0)
    pgpass
    databases = pgdatabases
    # connect only to first database and get information for all databases through SQL queries
    con = PG.connect(host: config[:hostname],
                     dbname: databases.first,
                     user: config[:user],
                     password: config[:password],
                     port: config[:port],
                     connect_timeout: config[:timeout])

    databases.each do |database|
      request = [
        'SELECT mode, count(mode) AS count FROM pg_locks',
        'WHERE database = (SELECT oid FROM pg_database WHERE datname = $1)',
        'GROUP BY mode'
      ]

      con.exec_params(request.join(' '), [database]) do |result|
        result.each do |row|
          lock_name = row['mode'].downcase.to_sym
          locks_per_type[lock_name] = row['count']
        end
      end

      locks_per_type.each do |lock_type, count|
        output "#{config[:scheme]}.locks.#{database}.#{lock_type}", count, timestamp
      end
    end

    ok
  end
end
