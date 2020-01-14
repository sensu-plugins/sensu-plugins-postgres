module Pgdatabases
  def pgdatabases
    if config[:databases].nil?
      con = PG.connect(host: config[:hostname],
                       dbname: config[:database],
                       user: config[:user],
                       password: config[:password],
                       port: config[:port],
                       connect_timeout: config[:timeout])

      dbs = con.exec('SELECT datname FROM pg_database').map { |r| r['datname'] } - %w[template0]

      con.close

      dbs
    else
      config[:databases].split(',').map(&:strip)
    end
  end
end
