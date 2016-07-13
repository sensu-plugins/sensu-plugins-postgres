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

require 'pg'
require 'sensu-plugin/metric/cli'
require 'socket'

class CheckpostgresReplicationStatus < Sensu::Plugin::Metric::CLI::Graphite
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
         description: 'Database NAME',
         default: 'postgres'

  option :user,
         short: '-u',
         long: '--username=VALUE',
         description: 'Database username'

  option :pass,
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
         long: '--port PORT',
         default: 5432

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT',
         default: nil

  def run
    # Establishing connections to the master
    conn_master = PG.connect(host: config[:master_host],
                             dbname: config[:database],
                             user: config[:user],
                             password: config[:password],
                             connect_timeout: config[:timeout])
    res1 = conn_master.exec('SELECT pg_current_xlog_location()').getvalue(0, 0)
    m_segbytes = conn_master.exec('SHOW wal_segment_size').getvalue(0, 0).sub(/\D+/, '').to_i << 20
    conn_master.close

    def lag_compute(res1, res, m_segbytes) # rubocop:disable NestedMethodDefinition
      m_segment, m_offset = res1.split(/\//)
      s_segment, s_offset = res.split(/\//)
      ((m_segment.hex - s_segment.hex) * m_segbytes) + (m_offset.hex - s_offset.hex)
    end

    # Establishing connections to the slave
    conn_slave = PG.connect(host: config[:slave_host],
                            dbname: config[:database],
                            user: config[:user],
                            password: config[:password],
                            connect_timeout: config[:timeout])
    res = conn_slave.exec('SELECT pg_last_xlog_receive_location()').getvalue(0, 0)
    conn_slave.close

    # Compute lag
    lag = lag_compute(res1, res, m_segbytes)
    output config[:scheme].to_s, lag

    ok
  end
end
