#! /usr/bin/env ruby
# frozen_string_literal: false

#
#   metrics-postgres-relation-size.rb
#
# DESCRIPTION:
#
#   This plugin collects postgres the total size of the biggest tables.
#
#   https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-ADMIN-DBOBJECT
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
#   ./metric-postgres-relation-size.rb -u db_user -p db_pass -h db_host -d db
#
# NOTES:
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
         description: 'Database name',
         short: '-d DB',
         long: '--db DB'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to $queue_name.$metric',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.postgresql"

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT',
         default: nil

  option :limit,
         description: 'Limit query to this many results',
         short: '-L LIMIT',
         login: '--limit LIMIT',
         default: 25

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

    # https://wiki.postgresql.org/wiki/Disk_Usage
    request = [
      "SELECT nspname || '.' || relname AS relation,
       pg_total_relation_size(C.oid) AS total_size
       FROM pg_class C
       LEFT JOIN pg_namespace N on (N.oid = C.relnamespace)
       WHERE nspname NOT IN ('pg_catalog', 'information_schema')
       ORDER BY pg_total_relation_size(C.oid) DESC
       LIMIT '#{config[:limit]}'"
    ]

    con.exec(request.join(' ')) do |result|
      result.each do |row|
        output "#{config[:scheme]}.size.#{config[:database]}.#{row['relation']}", row['total_size'], timestamp
      end
    end

    ok
  end
end
