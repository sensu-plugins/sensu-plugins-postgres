module Pgpass
  def read_pgpass(pg_pass_file)
    File.readlines(pg_pass_file).each do |line|
      if line.start_with?('#')
        # Perform no action. Line is a comment
        next
      else
        return line.strip.split(':')
      end
    end
  end

  def pgpass
    if File.file?(config[:pgpass])
      pgpass = Hash[%i[hostname port database user password].zip(read_pgpass(config[:pgpass]))]
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
