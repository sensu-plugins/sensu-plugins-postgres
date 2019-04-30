#! /usr/bin/env ruby
#
#   metric-postgres-connections
#
# DESCRIPTION:
#
#   This plugin collects postgres connection metrics
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
#   ./metric-postgres-connections.rb -u db_user -p db_pass -h db_host -d db
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
         default: "#{ENV['HOME']}/.pgpass"

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
         description: 'Database names, separated by ";"',
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
    pgpass
    databases = pgdatabases
    con     = PG.connect(host: config[:hostname],
                         dbname: databases.first,
                         user: config[:user],
                         password: config[:password],
                         port: config[:port],
                         connect_timeout: config[:timeout])
    request = [
      "select case when count(*) = 1 then 'waiting' else",
      "'case when wait_event_type is null then false else true end' end as wait_col",
      'from information_schema.columns',
      "where table_name = 'pg_stat_activity' and table_schema = 'pg_catalog'",
      "and column_name = 'waiting'"
    ]
    wait_col = con.exec(request.join(' ')).first['wait_col']

    databases.each do |database|
      request = [
        "select count(*), #{wait_col} as waiting from pg_stat_activity",
        "where datname = '#{database}' group by #{wait_col}"
      ]

      metrics = {
        active: 0,
        waiting: 0,
        total: 0
      }
      con.exec(request.join(' ')) do |result|
        result.each do |row|
          if row['waiting'] == 't'
            metrics[:waiting] = row['count']
          elsif row['waiting'] == 'f'
            metrics[:active] = row['count']
          end
        end
      end

      metrics[:total] = (metrics[:waiting].to_i + metrics[:active].to_i)

      metrics.each do |metric, value|
        output "#{config[:scheme]}.connections.#{database}.#{metric}", value, timestamp
      end
    end

    ok
  end
end
