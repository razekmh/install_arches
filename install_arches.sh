
sudo apt-get update -y
sudo apt-get full-upgrade -y 

sudo apt-get install -y make software-properties-common build-essential libxml2-dev libproj-dev libjson-c-dev xsltproc docbook-xsl docbook-mathml libgdal-dev libpq-dev python3-venv

# install_postgres
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install postgresql-12 postgresql-contrib-12 -y
sudo apt-get install postgresql-12-postgis-3 -y
sudo -u postgres psql -d postgres -c "ALTER USER postgres with encrypted password 'postgis';"
sudo echo "*:*:*:postgres:postgis" >> ~/.pgpass
sudo chmod 600 ~/.pgpass
sudo chmod 666 /etc/postgresql/12/main/postgresql.conf
sudo chmod 666 /etc/postgresql/12/main/pg_hba.conf
sudo echo "standard_conforming_strings = off" >> /etc/postgresql/12/main/postgresql.conf
sudo echo "listen_addresses = '*'" >> /etc/postgresql/12/main/postgresql.conf
sudo echo "#TYPE   DATABASE  USER  CIDR-ADDRESS  METHOD" > /etc/postgresql/12/main/pg_hba.conf
sudo echo "local   all       all                 trust" >> /etc/postgresql/12/main/pg_hba.conf
sudo echo "host    all       all   127.0.0.1/32  trust" >> /etc/postgresql/12/main/pg_hba.conf
sudo echo "host    all       all   ::1/128       trust" >> /etc/postgresql/12/main/pg_hba.conf
sudo echo "host    all       all   0.0.0.0/0     md5" >> /etc/postgresql/12/main/pg_hba.conf
sudo service postgresql restart

sudo -u postgres createdb -E UTF8 -T template0 --locale=en_US.utf8 template_postgis
sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis'"
sudo -u postgres psql -d template_postgis -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -d template_postgis -c "CREATE EXTENSION \"uuid-ossp\";"
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

# install couchdb
sudo apt update && sudo apt install -y curl apt-transport-https gnupg
curl https://couchdb.apache.org/repo/keys.asc | gpg --dearmor | sudo tee /usr/share/keyrings/couchdb-archive-keyring.gpg >/dev/null 2>&1
source /etc/os-release
echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ ${VERSION_CODENAME} main" \
	    | sudo tee /etc/apt/sources.list.d/couchdb.list >/dev/null
sudo apt-get update
sudo apt-get install -y couchdb

