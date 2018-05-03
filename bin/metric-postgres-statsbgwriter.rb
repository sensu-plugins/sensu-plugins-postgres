#! /usr/bin/env ruby
#
#   metric-postgres-statsbgwriter
#
# DESCRIPTION:
#
#   This plugin collects postgres database bgwriter metrics
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
#   ./metric-postgres-statsbgwriter.rb -u db_user -p db_pass -h db_host -d db
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

  include Pgpass

  def run
    timestamp = Time.now.to_i
    pgpass
    con     = PG.connect(host: config[:hostname],
                         dbname: 'postgres',
                         user: config[:user],
                         password: config[:password],
                         port: config[:port],
                         connect_timeout: config[:timeout])
    request = [
      'select checkpoints_timed, checkpoints_req,',
      'buffers_checkpoint, buffers_clean,',
      'maxwritten_clean, buffers_backend,',
      'buffers_alloc',
      'from pg_stat_bgwriter'
    ]
    con.exec(request.join(' ')) do |result|
      result.each do |row|
        output "#{config[:scheme]}.bgwriter.#{config[:database]}.checkpoints_timed", row['checkpoints_timed'], timestamp
        output "#{config[:scheme]}.bgwriter.#{config[:database]}.checkpoints_req", row['checkpoints_req'], timestamp
        output "#{config[:scheme]}.bgwriter.#{config[:database]}.buffers_checkpoint", row['buffers_checkpoint'], timestamp
        output "#{config[:scheme]}.bgwriter.#{config[:database]}.buffers_clean", row['buffers_clean'], timestamp
        output "#{config[:scheme]}.bgwriter.#{config[:database]}.maxwritten_clean", row['maxwritten_clean'], timestamp
        output "#{config[:scheme]}.bgwriter.#{config[:database]}.buffers_backend", row['buffers_backend'], timestamp
        output "#{config[:scheme]}.bgwriter.#{config[:database]}.buffers_alloc", row['buffers_alloc'], timestamp
      end
    end

    ok
  end
end
