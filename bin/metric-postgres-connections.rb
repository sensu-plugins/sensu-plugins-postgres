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

require 'sensu-plugin/metric/cli'
require 'pg'
require 'socket'

class PostgresStatsDBMetrics < Sensu::Plugin::Metric::CLI::Graphite
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
         long: '--hostname HOST',
         default: 'localhost'

  option :port,
         description: 'Database port',
         short: '-P PORT',
         long: '--port PORT',
         default: 5432

  option :database,
         description: 'Database name',
         short: '-d DB',
         long: '--db DB',
         default: 'postgres'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to $queue_name.$metric',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.postgresql"

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT',
         default: nil

  def run
    timestamp = Time.now.to_i

    con     = PG.connect(host: config[:hostname],
                         dbname: config[:database],
                         user: config[:user],
                         password: config[:password],
                         connect_timeout: config[:timeout])
    request = [
      'select count(*), waiting from pg_stat_activity',
      "where datname = '#{config[:database]}' group by waiting"
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
      output "#{config[:scheme]}.connections.#{config[:database]}.#{metric}", value, timestamp
    end

    ok
  end
end
