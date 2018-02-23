#!/bin/bash
#
# Set up a super simple web server and make it accept GET and POST requests
# for Sensu plugin testing.
#

set -e

# base utilities that need to exist to start bootatraping
apt-get update
apt-get install -y wget

# setup the rubies
source /etc/profile
DATA_DIR=/tmp/kitchen/data
RUBY_HOME=${MY_RUBY_HOME}

# setup a .pgpass file
cat << EOF > /tmp/.pgpass
*:5432:*:postgres:<REDACTED>
EOF

# Start bootatraping

## install some required deps for pg_gem to install
apt-get install -y libpq-dev build-essential

# setup postgres server
## TODO: multiple postgres versions and replication the versions should probably
## be matrixed but wanted to start as small as possible initially.


# End of Actual bootatrap

# Install gems
cd $DATA_DIR
SIGN_GEM=false gem build sensu-plugins-postgres.gemspec
gem install sensu-plugins-postgres-*.gem
