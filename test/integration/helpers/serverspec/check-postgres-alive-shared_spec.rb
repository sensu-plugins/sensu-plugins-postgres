# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'check-postgres-alive.rb'
check = "#{gem_path}/#{check_name}"
pg_user = 'postgres'
pg_password = '<REDACTED>'
# TODO: fix up the hostname to be pulled in via the suite based on the version being tested
pg_host = 'sensu-postgres-10'

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

# NOTE: This ia a TERRIBLE idea and you should never specify a cleartext
# password on the cli like this. you should use the pgpass or sensu tokens:
# https://sensuapp.org/docs/1.1/reference/checks.html#check-token-substitution
# do not use this method for anything but testing.
describe command("#{check} --user #{pg_user} --password \'#{pg_password}\' --hostname #{pg_host}") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/CheckPostgres OK: Server version: {"version"=>"PostgreSQL/) }
end

describe command("#{check} --hostname #{pg_host} --pgpass /tmp/.pgpass") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/CheckPostgres OK: Server version: {"version"=>"PostgreSQL/) }
end
