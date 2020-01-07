#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   metric-postgres-statsdb
#
# DESCRIPTION:
#
#   This plugin collects postgres database metrics from the pg_stat_database table
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
#   ./metric-postgres-statsdb.rb -u db_user -p db_pass -h db_host -d db
#
# NOTES:
#   Requires PSQL `track_counts` `track_io_timing` for some metrics enabled
#
# LICENSE:
#   Copyright (c) 2012 Kwarter, Inc <platforms@kwarter.com>
#   Author Gilles Devaux <gilles.devaux@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-postgres/pgpass'
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

  option :database,
         description: 'Database to connect on',
         short: '-d DB',
         long: '--db DB',
         default: 'postgres'

  option :all_databases,
         description: 'Get stats for all available databases',
         short: '-a',
         long: '--all-databases',
         boolean: true,
         default: false

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

  def run
    timestamp = Time.now.to_i
    pgpass
    con = PG.connect(host: config[:hostname],
                     dbname: config[:database],
                     user: config[:user],
                     password: config[:password],
                     port: config[:port],
                     connect_timeout: config[:timeout])

    query = 'SELECT * FROM pg_stat_database'
    params = []
    unless config[:all_databases]
      query += ' WHERE datname = $1'
      params.push config[:database]
    end

    con.exec_params(query, params) do |result|
      result.each do |row|
        database = row['datname']

        row.each do |key, value|
          next if %w[datid datname stats_reset].include?(key)

          output "#{config[:scheme]}.statsdb.#{database}.#{key}", value.to_s, timestamp
        end
      end
    end

    ok
  end
end
