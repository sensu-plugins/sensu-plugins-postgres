#! /usr/bin/env ruby
#
#   metric-postgres-dbsize
#
# DESCRIPTION:
#
#   This plugin collects postgres database size metrics
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
#   ./metric-postgres-dbsize.rb -u db_user -p db_pass -h db_host -d db
#   ./metric-postgres-dbsize.rb -u db_user -p db_pass -h db_host -d 'db1,db2'
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
    pgpass
    databases = pgdatabases
    con = PG.connect(host: config[:hostname],
                     dbname: databases.first,
                     user: config[:user],
                     password: config[:password],
                     port: config[:port],
                     connect_timeout: config[:timeout])

    databases.each do |database|
      con.exec_params('select pg_database_size($1)', [database]) do |result|
        result.each do |row|
          output "#{config[:scheme]}.size.#{database}", row['pg_database_size'], timestamp
        end
      end
    end

    ok
  end
end
