#! /usr/bin/env ruby
# frozen_string_literal: true

#
# check-postgres-query
#
# DESCRIPTION:
#   This plugin queries a PostgreSQL database. It alerts when the numeric
#   result hits a threshold. Can optionally alert on the number of tuples
#   (rows) returned by the query.
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
#   gem: dentaku
#
# USAGE:
#   check-postgres-query.rb -u db_user -p db_pass -h db_host -d db -q 'select foo from bar' -w 'value > 5' -c 'value > 10'
#
# NOTES:
#
# LICENSE:
#   Copyright 2015, Eric Heydrick <eheydrick@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-postgres/pgpass'
require 'sensu-plugin/check/cli'
require 'pg'
require 'dentaku'

# Check PostgresSQL Query
class CheckPostgresQuery < Sensu::Plugin::Check::CLI
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

  option :query,
         description: 'Database query to execute',
         short: '-q QUERY',
         long: '--query QUERY',
         required: true

  option :regex_pattern,
         description: 'Regex pattern to match on query results and alert on if it does not match',
         short: '-r REGEX',
         long: '--regex-pattern REGEX'

  option :check_tuples,
         description: 'Check against the number of tuples (rows) returned by the query',
         short: '-t',
         long: '--tuples',
         boolean: true,
         default: false

  option :warning,
         description: 'Warning threshold expression',
         short: '-w WARNING',
         long: '--warning WARNING',
         default: nil

  option :critical,
         description: 'Critical threshold expression',
         short: '-c CRITICAL',
         long: '--critical CRITICAL',
         default: nil

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT',
         default: nil

  include Pgpass

  def run
    begin
      pgpass
      con = PG.connect(host: config[:hostname],
                       dbname: config[:database],
                       user: config[:user],
                       password: config[:password],
                       port: config[:port],
                       connect_timeout: config[:timeout])
      res = con.exec(config[:query].to_s)
    rescue PG::Error => e
      unknown "Unable to query PostgreSQL: #{e.message}"
    end

    value = if config[:check_tuples]
              res.ntuples
            else
              res.first.values.first.to_f
            end

    calc = Dentaku::Calculator.new
    if config[:critical] && calc.evaluate(config[:critical], value: value)
      critical "Results: #{res.values}"
    elsif config[:warning] && calc.evaluate(config[:warning], value: value)
      warning "Results: #{res.values}"
    elsif config[:regex_pattern] && (res.getvalue(0, 0) !~ /#{config[:regex_pattern]}/)
      critical "Query result #{res.getvalue(0, 0)} doesn't match configured regex #{config[:regex_pattern]}"
    else
      ok 'Query OK'
    end
  end
end
