#!/usr/bin/env ruby
#
# check-postgres-connections
#
# DESCRIPTION:
#   This plugin checks the number of connections to a postgresql database and
#   alerts when the number or percent crosses a threshold. Defaults to checking
#   number of connections unless the --percentage flag is used in which case the
#   percentage of max connections is checked.
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: pg
#   gem: sensu-plugin
#
# USAGE:
#   # warn when connections hit 250, critical when 400
#   check-postgres-connections.rb -u db_user -p db_pass -h db_host -d db -w 250 -c 400
#   # warn when connections hit 80%, critical when 95%
#   check-postgres-connections.rb -u db_user -p db_pass -h db_host -d db -w 80 -c 95 --percentage
#
# NOTES:
#
# LICENSE:
#   Copyright 2016, Eric Heydrick <eheydrick@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'pg'

class CheckPostgresConnections < Sensu::Plugin::Check::CLI
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

  option :warning,
         description: 'Warning threshold number or % of connections. (default: 200 connections)',
         short: '-w WARNING',
         long: '--warning WARNING',
         default: 200,
         proc: proc(&:to_i)

  option :critical,
         description: 'Critical threshold number or % of connections. (default: 250 connections)',
         short: '-c CRITICAL',
         long: '--critical CRITICAL',
         default: 250,
         proc: proc(&:to_i)

  option :use_percentage,
         description: 'Use percentage of max connections used instead of the absolute number of connections',
         short: '-a',
         long: '--percentage',
         boolean: true,
         default: false

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT',
         default: nil

  def run
    begin
      con = PG.connect(host: config[:hostname],
                       dbname: config[:database],
                       user: config[:user],
                       password: config[:password],
                       connect_timeout: config[:timeout])
      max_conns = con.exec('SHOW max_connections').getvalue(0, 0).to_i
      current_conns = con.exec('SELECT count(*) from pg_stat_activity').getvalue(0, 0).to_i
    rescue PG::Error => e
      unknown "Unable to query PostgreSQL: #{e.message}"
    end

    percent = (current_conns.to_f / max_conns.to_f * 100).to_i

    if config[:use_percentage]
      message = "PostgreSQL connections at #{percent}%, #{current_conns} out of #{max_conns} connections"
      if percent >= config[:critical]
        critical message
      elsif percent >= config[:warning]
        warning message
      else
        ok "PostgreSQL connections under threshold: #{percent}%, #{current_conns} out of #{max_conns} connections"
      end
    else
      message = "PostgreSQL connections at #{current_conns} out of #{max_conns} connections"
      if current_conns >= config[:critical]
        critical message
      elsif current_conns >= config[:warning]
        warning message
      else
        ok "PostgreSQL connections under threshold: #{current_conns} out of #{max_conns} connections"
      end
    end
  end
end
