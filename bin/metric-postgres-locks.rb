#! /usr/bin/env ruby
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

  option :db,
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

    locks_per_type = Hash.new(0)

    con     = PG.connect(host: config[:hostname],
                         dbname: config[:database],
                         user: config[:user],
                         password: config[:password],
                         connect_timeout: config[:timeout])
    request = [
      'SELECT mode, count(mode) FROM pg_locks',
      "where database = (select oid from pg_database where datname = '#{config[:db]}')",
      'group by mode'
    ]

    con.exec(request.join(' ')) do |result|
      result.each do |row|
        lock_name = row['mode'].downcase.to_sym
        locks_per_type[lock_name] += 1
      end
    end

    locks_per_type.each do |lock_type, count|
      output "#{config[:scheme]}.locks.#{config[:db]}.#{lock_type}", count, timestamp
    end

    ok
  end
end
