module Pgpass
  def pgpass
    if File.file?(config[:pgpass])
      pgpass = Hash[%i[hostname port database user password].zip(File.readlines(config[:pgpass])[0].strip.split(':'))]
      pgpass[:database] = nil if pgpass[:database] == '*'
      pgpass.each do |k, v|
        config[k] ||= v
      end
    else
      config[:hostname] ||= ENV['PGHOST']     || 'localhost'
      config[:port]     ||= ENV['PGPORT']     || 5432
      config[:database] ||= ENV['PGDATABASE'] || 'postgres'
      config[:user]     ||= ENV['PGUSER']     || 'postgres'
      config[:password] ||= ENV['PGPASSWORD']
    end
  end
end
