#! /usr/bin/env ruby
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

require 'sensu-plugin/check/cli'
require 'pg'
require 'dentaku'

# Check PostgresSQL Query
class CheckPostgresQuery < Sensu::Plugin::Check::CLI
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

  option :query,
         description: 'Database query to execute',
         short: '-q QUERY',
         long: '--query QUERY',
         required: true

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

  def run
    begin
      con = PG.connect(host: config[:hostname],
                       dbname: config[:database],
                       user: config[:user],
                       password: config[:password],
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
    else
      ok 'Query OK'
    end
  end
end
