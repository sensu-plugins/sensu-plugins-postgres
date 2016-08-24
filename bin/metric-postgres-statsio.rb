#! /usr/bin/env ruby
#
#   metric-postgres-statsio
#
# DESCRIPTION:
#
#   This plugin collects postgres database IO metrics
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
#   ./metric-postgres-statsio.rb -u db_user -p db_pass -h db_host -d db -s scope
#
# NOTES:
#   Requires PSQL `track_io_timing` enabled
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

class PostgresStatsIOMetrics < Sensu::Plugin::Metric::CLI::Graphite
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

  option :scope,
         description: 'Scope, see http://www.postgresql.org/docs/9.2/static/monitoring-stats.html',
         short: '-s SCOPE',
         long: '--scope SCOPE',
         default: 'user'

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
      'select sum(heap_blks_read) as heap_blks_read, sum(heap_blks_hit) as heap_blks_hit,',
      'sum(idx_blks_read) as idx_blks_read, sum(idx_blks_hit) as idx_blks_hit,',
      'sum(toast_blks_read) as toast_blks_read, sum(toast_blks_hit) as toast_blks_hit,',
      'sum(tidx_blks_read) as tidx_blks_read, sum(tidx_blks_hit) as tidx_blks_hit',
      "from pg_statio_#{config[:scope]}_tables"
    ]
    con.exec(request.join(' ')) do |result|
      result.each do |row|
        output "#{config[:scheme]}.statsio.#{config[:database]}.heap_blks_read", row['heap_blks_read'], timestamp
        output "#{config[:scheme]}.statsio.#{config[:database]}.heap_blks_hit", row['heap_blks_hit'], timestamp
        output "#{config[:scheme]}.statsio.#{config[:database]}.idx_blks_read", row['idx_blks_read'], timestamp
        output "#{config[:scheme]}.statsio.#{config[:database]}.idx_blks_hit", row['idx_blks_hit'], timestamp
        output "#{config[:scheme]}.statsio.#{config[:database]}.toast_blks_read", row['toast_blks_read'], timestamp
        output "#{config[:scheme]}.statsio.#{config[:database]}.toast_blks_hit", row['toast_blks_hit'], timestamp
        output "#{config[:scheme]}.statsio.#{config[:database]}.tidx_blks_read", row['tidx_blks_read'], timestamp
        output "#{config[:scheme]}.statsio.#{config[:database]}.tidx_blks_hit", row['tidx_blks_hit'], timestamp
      end
    end

    ok
  end
end
