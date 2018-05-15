#! /usr/bin/env ruby
#
#   metric-postgres-graphite
#
# DESCRIPTION:
#
#   This plugin collects postgres replication lag metrics
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
#   ./metric-postgres-graphite.rb -m master_host -s slave_host -d db -u db_user -p db_pass
#
# NOTES:
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-postgres/pgpass'
require 'pg'
require 'sensu-plugin/metric/cli'
require 'socket'

class CheckpostgresReplicationStatus < Sensu::Plugin::Metric::CLI::Graphite
  option :pgpass,
         description: 'Pgpass file',
         short: '-f FILE',
         long: '--pgpass',
         default: ENV['PGPASSFILE'] || "#{ENV['HOME']}/.pgpass"

  option :master_host,
         short: '-m',
         long: '--master=HOST',
         description: 'PostgreSQL master HOST'

  option :slave_host,
         short: '-s',
         long: '--slave=HOST',
         description: 'PostgreSQL slave HOST',
         default: 'localhost'

  option :database,
         short: '-d',
         long: '--database=NAME',
         description: 'Database NAME'

  option :user,
         short: '-u',
         long: '--username=VALUE',
         description: 'Database username'

  option :password,
         short: '-p',
         long: '--password=VALUE',
         description: 'Database password'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-g SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.postgres.replication_lag"

  option :port,
         description: 'Database port',
         short: '-P PORT',
         long: '--port PORT'

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT',
         default: nil

  include Pgpass

  def compute_lag(master, slave, m_segbytes)
    m_segment, m_offset = master.split('/')
    s_segment, s_offset = slave.split('/')
    ((m_segment.hex - s_segment.hex) * m_segbytes) + (m_offset.hex - s_offset.hex)
  end

  def check_vsn(conn)
    pg_vsn = conn.exec("SELECT current_setting('server_version')").getvalue(0, 0)
    pg_vsn = pg_vsn.split(' ')[0]
    Gem::Version.new(pg_vsn) < Gem::Version.new('10.0') && Gem::Version.new(pg_vsn) >= Gem::Version.new('9.0')
  end

  def run
    # Establishing connections to the master
    pgpass
    conn_master = PG.connect(host: config[:master_host],
                             dbname: config[:database],
                             user: config[:user],
                             password: config[:password],
                             port: config[:port],
                             connect_timeout: config[:timeout])
    master = if check_vsn(conn_master)
               conn_master.exec('SELECT pg_current_xlog_location()').getvalue(0, 0)
             else
               conn_master.exec('SELECT pg_current_wal_lsn()').getvalue(0, 0)
             end
    m_segbytes = conn_master.exec('SHOW wal_segment_size').getvalue(0, 0).sub(/\D+/, '').to_i << 20
    conn_master.close

    # Establishing connections to the slave
    conn_slave = PG.connect(host: config[:slave_host],
                            dbname: config[:database],
                            user: config[:user],
                            password: config[:password],
                            port: config[:port],
                            connect_timeout: config[:timeout])
    slave = if check_vsn(conn_slave)
              conn_slave.exec('SELECT pg_last_xlog_receive_location()').getvalue(0, 0)
            else
              conn_slave.exec('SELECT pg_last_wal_replay_lsn()').getvalue(0, 0)
            end
    conn_slave.close

    # Compute lag
    lag = compute_lag(master, slave, m_segbytes)
    output config[:scheme].to_s, lag

    ok
  end
end
