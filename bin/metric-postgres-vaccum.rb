#! /usr/bin/env ruby
# frozen_string_literal: true

# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: pg
#
# USAGE:
#   ./metric-postgres-vaccum.rb -u db_user -p db_pass -h db_host -d db
#
# NOTES:
#   Requires PSQL `track_counts` `track_io_timing` for some metrics enabled
#
# LICENSE:
#   Copyright (c) 2020 Airbrake Technologies, Inc <support@airbrake.io>
#   Author Patrick Humpal <patrick@netvilla.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-postgres/pgpass'
require 'sensu-plugin/metric/cli'
require 'pg'
require 'socket'

class PostgresVacuumDBMetrics < Sensu::Plugin::Metric::CLI::Graphite
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

  def phase_mapping(vacuum_phase)
    ['initializing',
     'scanning heap',
     'vacuuming indexes',
     'vacuuming heap',
     'cleaning up indexes',
     'truncating heap',
     'performing final cleanup'].find_index(vacuum_phase)
  end

  def run
    timestamp = Time.now.to_i
    pgpass
    con = PG.connect(host: config[:hostname],
                     dbname: config[:database],
                     user: config[:user],
                     password: config[:password],
                     port: config[:port],
                     connect_timeout: config[:timeout])

    query = 'SELECT * FROM pg_stat_progress_vacuum'
    params = []
    unless config[:all_databases]
      query += ' WHERE datname = $1'
      params.push config[:database]
    end

    con.exec_params(query, params) do |result|
      result.each do |row|
        database = row['datname']

        row.each do |key, value|
          next if %w[datid datname].include?(key)

          if key == 'phase'
            output "#{config[:scheme]}.vacuum.#{database}.phase", phase_mapping(value).to_s, timestamp
          else
            output "#{config[:scheme]}.vacuum.#{database}.#{key}", value.to_s, timestamp
          end
        end
      end
    end

    ok
  end
end
