#! /usr/bin/env ruby
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
      'select xact_commit, xact_rollback,',
      'blks_read, blks_hit,',
      'tup_returned, tup_fetched, tup_inserted, tup_updated, tup_deleted',
      "from pg_stat_database where datname='#{config[:database]}'"
    ]
    con.exec(request.join(' ')) do |result|
      result.each do |row|
        output "#{config[:scheme]}.statsdb.#{config[:database]}.xact_commit", row['xact_commit'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.xact_rollback", row['xact_rollback'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.blks_read", row['blks_read'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.blks_hit", row['blks_hit'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.tup_returned", row['tup_returned'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.tup_fetched", row['tup_fetched'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.tup_inserted", row['tup_inserted'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.tup_updated", row['tup_updated'], timestamp
        output "#{config[:scheme]}.statsdb.#{config[:database]}.tup_deleted", row['tup_deleted'], timestamp
      end
    end

    ok
  end
end
