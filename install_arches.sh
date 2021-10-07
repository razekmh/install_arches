
sudo apt-get update -y
sudo apt-get full-upgrade -y 

sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
sudo apt-get update -y
sudo apt-get install -y make software-properties-common build-essential libxml2-dev
  #sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable

sudo apt-get install -y build-essential
sudo apt-get install -y libxml2-dev
sudo apt-get install -y libproj-dev
sudo apt-get install -y libjson-c-dev
sudo apt-get install -y xsltproc
sudo apt-get install -y docbook-xsl
sudo apt-get install -y docbook-mathml
sudo apt-get install -y libgdal-dev
sudo apt-get install -y libpq-dev

# install_postgres
sudo apt update -y
sudo apt -y install gnupg2
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
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


# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update -y
sudo apt-get install yarn -y


# install elasticsearch
sudo apt-get install openjdk-8-jre-headless -y
sudo apt-get install apt-transport-https -y
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt-get update -y
sudo apt-get install elasticsearch -y 
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# create project
cd /opt
mkdir projects && cd projects
sudo apt-get install git python3-dev python3-venv -y
python3 -m venv ENV
source ENV/bin/activate
git clone -b stable/5.2.x https://github.com/archesproject/arches.git
cd arches
pip install -e . 
pip install -r arches/install/requirements_dev.txt 
cd ..
arches-project create my_project
cd my_project
python manage.py setup_db -y
python manage.py packages -o load_package -s https://github.com/archesproject/arches-example-pkg/archive/master.zip -db

