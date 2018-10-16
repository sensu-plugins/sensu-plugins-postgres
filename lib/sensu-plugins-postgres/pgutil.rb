module PgUtil
  def check_vsn_newer_than_postgres9(conn)
    pg_vsn = conn.exec("SELECT current_setting('server_version')").getvalue(0, 0)
    pg_vsn = pg_vsn.split(' ')[0]
    Gem::Version.new(pg_vsn) < Gem::Version.new('10.0') && Gem::Version.new(pg_vsn) >= Gem::Version.new('9.0')
  end

  def compute_lag(master, slave, m_segbytes)
    m_segment, m_offset = master.split('/')
    s_segment, s_offset = slave.split('/')
    ((m_segment.hex - s_segment.hex) * m_segbytes) + (m_offset.hex - s_offset.hex)
  end
end
