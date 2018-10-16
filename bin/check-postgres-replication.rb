#! /usr/bin/env ruby
#
#   check-postgres-replication
#
# DESCRIPTION:
#
#   This plugin checks postgresql replication lag
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: pg
#
# USAGE:
#   ./check-postgres-replication.rb -m master_host -s slave_host -P port -d db -u db_user -p db_pass -w warn_threshold -c crit_threshold
#
# NOTES:
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-postgres/pgpass'
require 'sensu-plugins-postgres/pgutil'
require 'sensu-plugin/check/cli'
require 'pg'

class CheckPostgresReplicationStatus < Sensu::Plugin::Check::CLI
  option :pgpass,
         description: 'Pgpass file',
         short: '-f FILE',
         long: '--pgpass',
         default: ENV['PGPASSFILE'] || "#{ENV['HOME']}/.pgpass"

  option(:master_host,
         short: '-m',
         long: '--master-host=HOST',
         description: 'PostgreSQL master HOST')

  option(:slave_host,
         short: '-s',
         long: '--slave-host=HOST',
         description: 'PostgreSQL slave HOST',
         default: 'localhost')

  option(:port,
         short: '-P',
         long: '--port=PORT',
         description: 'PostgreSQL port')

  option(:database,
         short: '-d',
         long: '--database=NAME',
         description: 'Database NAME')

  option(:user,
         short: '-u',
         long: '--user=USER',
         description: 'Database USER')

  option(:password,
         short: '-p',
         long: '--password=PASSWORD',
         description: 'Database PASSWORD')

  option(:ssl,
         short: '-S',
         long: '--ssl',
         boolean: true,
         description: 'Require SSL')

  option(:warn,
         short: '-w',
         long: '--warning=VALUE',
         description: 'Warning threshold for replication lag (in MB)',
         default: 900,
         # #YELLOW
         proc: lambda { |s| s.to_i }) # rubocop:disable Lambda

  option(:crit,
         short: '-c',
         long: '--critical=VALUE',
         description: 'Critical threshold for replication lag (in MB)',
         default: 1800,
         # #YELLOW
         proc: lambda { |s| s.to_i }) # rubocop:disable Lambda

  option(:timeout,
         short: '-T',
         long: '--timeout',
         default: nil,
         description: 'Connection timeout (seconds)')

  include Pgpass
  include PgUtil

  def run
    ssl_mode = config[:ssl] ? 'require' : 'prefer'

    # Establishing connection to the master
    pgpass
    conn_master = PG.connect(host: config[:master_host],
                             dbname: config[:database],
                             user: config[:user],
                             password: config[:password],
                             port: config[:port],
                             sslmode: ssl_mode,
                             connect_timeout: config[:timeout])

    master = if check_vsn_newer_than_postgres9(conn_master)
               conn_master.exec('SELECT pg_current_xlog_location()').getvalue(0, 0)
             else
               conn_master.exec('SELECT pg_current_wal_lsn()').getvalue(0, 0)
             end
    m_segbytes = conn_master.exec('SHOW wal_segment_size').getvalue(0, 0).sub(/\D+/, '').to_i << 20
    conn_master.close

    # Establishing connection to the slave
    conn_slave = PG.connect(host: config[:slave_host],
                            dbname: config[:database],
                            user: config[:user],
                            password: config[:password],
                            port: config[:port],
                            sslmode: ssl_mode,
                            connect_timeout: config[:timeout])

    slave = if check_vsn_newer_than_postgres9(conn_slave)
              conn_slave.exec('SELECT pg_last_xlog_receive_location()').getvalue(0, 0)
            else
              conn_slave.exec('SELECT pg_last_wal_replay_lsn()').getvalue(0, 0)
            end
    conn_slave.close

    # Computing lag
    lag = compute_lag(master, slave, m_segbytes)
    lag_in_mb = (lag.to_f / 1024 / 1024).abs

    message = "replication delayed by #{lag_in_mb}MB :: master:#{master} slave:#{slave} m_segbytes:#{m_segbytes}"

    if lag_in_mb >= config[:crit]
      critical message
    elsif lag_in_mb >= config[:warn]
      warning message
    else
      ok message
    end
  end
end
