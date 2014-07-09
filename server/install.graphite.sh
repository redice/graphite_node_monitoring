#!/bin/bash
# Install Ruby
sudo yum -y install rubyutoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel
sudo yum -y install ruby-rdoc ruby-devel rpm-build
sudo yum -y install python-pip 
sudo yum -y install gcc g++ make automake autoconf libtool

# Update the latest softwares
sudo yum -y update

# Install Ruby Gems
sudo yum -y install rubygems

# Install Rails
sudo gem update
sudo gem update --system
#sudo gem install rails
# ERROR:  Error installing rails:
# 	 activesupport requires Ruby version >= 1.9.3.

# Install fpm with gem
#sudo gem sources --quiet --add https://rubygems.org
sudo gem install fpm
#sudo gem install --source http://rubygems.org/downloads/fpm-1.0.2.gem

# fpm -s <source type> -t <target type> [list of sources]...
# "Source type" is what your package is coming from; a directory (dir), a rubygem (gem), an rpm (rpm), a python package (python), a php pear module (pear), etc.
# "Target type" is what your output package form should be. Most common are "rpm" and "deb" but others exist (solaris, etc)

# Generate python-carbon-0.9.10-1.noarch.rpm
sudo fpm -s python -t rpm \
    -d python-setuptools \
    -d Django -d django-tagging \
    -d python-devel \
    -d python-twisted \
    -d python-memcached \
    -d python-sqlite2 \
    -d bitmap -d bitmap-console-fonts -d bitmap-fixed-fonts -d bitmap-fonts-compat \
    -d bitmap-lucida-typewriter-fonts -d bitmap-miscfixed-fonts \
    -d pycairo \
    carbon

# Generate python-whisper-0.9.12-1.noarch.rpm
sudo fpm -s python -t rpm \
    -d python-setuptools \
    -d Django -d django-tagging \
    -d python-devel \
    -d python-twisted \
    -d python-memcached \
    -d python-sqlite2 \
    -d bitmap -d bitmap-console-fonts -d bitmap-fixed-fonts -d bitmap-fonts-compat \
    -d bitmap-lucida-typewriter-fonts -d bitmap-miscfixed-fonts \
    -d pycairo \
    whisper

# Generate python-graphite-web-0.9.12-1.noarch.rpm
sudo fpm -s python -t rpm \
    -d python-setuptools \
    -d Django -d django-tagging \
    -d python-devel \
    -d python-twisted \
    -d python-memcached \
    -d python-sqlite2 \
    -d bitmap -d bitmap-console-fonts -d bitmap-fixed-fonts -d bitmap-fonts-compat \
    -d bitmap-lucida-typewriter-fonts -d bitmap-miscfixed-fonts \
    -d pycairo \
    -d python-gunicorn \
    graphite-web

# Install our custom Graphite RPM files
sudo yum -y install python-carbon-0.9.12-1.noarch.rpm python-graphite-web-0.9.12-1.noarch.rpm python-whisper-0.9.12-1.noarch.rpm

##########
# Installing prerequisites
sudo rpm -Uhv https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum -y install supervisor
sudo chkconfig supervisord on
sudo chmod 600 /etc/supervisord.conf

# Configure Graphite

# Set up the database used by Django/Graphite
sudo python /opt/graphite/webapp/graphite/manage.py syncdb

# Add a system account for Graphite
sudo groupadd -g 53012 graphite
sudo useradd -u 53012 -g 53012 -d /opt/graphite -s /bin/bash graphite -c "Graphite service account"
sudo chage -I -1 -E -1 -m -1 -M -1 -W -1 -E -1 graphite

# Configure ownership of graphite-web storage directory
sudo chown -R graphite:graphite /opt/graphite/storage

### Configure graphite-web ###
# Set up directories and permissions:
sudo mkdir -p /var/run/gunicorn-graphite
sudo chown -R graphite:graphite /var/run/gunicorn-graphite
sudo mkdir -p /var/log/gunicorn-graphite
sudo chown -R graphite:graphite /var/log/gunicorn-graphite

# Enable SECRET_KEY and change the value, for example: SECRET_KEY = 'z3ujbrkro4b1yebe0056'
# Enable sqlite3 access
sudo cp graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
sudo cp graphite/webapp/graphite/settings.py /opt/graphite/webapp/graphite/settings.py
sudo cp graphite/webapp/graphite/wsgi.py /opt/graphite/webapp/graphite/wsgi.py

# Add gunicorn to supervisord
cat supervisord/gunicorn.init >> /etc/supervisord.conf
# If you run into startup problems with gunicorn then increase the log level to see what is failing exactly:
#$ gunicorn_django --debug --log-level=debug ...

### Configure carbon-cache ###
sudo cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf
sudo cp /opt/graphite/conf/storage-aggregation.conf.example /opt/graphite/conf/storage-aggregation.conf

# Enable something
sudo cp graphite/conf/carbon.conf /opt/graphite/conf/carbon.conf

# Set up directories and permissions:
sudo mkdir -p /var/log/carbon
sudo chown -R graphite:graphite /var/log/carbon
sudo mkdir -p /var/run/carbon
sudo chown -R graphite:graphite /var/run/carbon

# Add carbon-cache to supervisord
cat supervisord/carbon.init >> /etc/supervisord.conf
# If you run into startup problems with carbon-cache then increase the log level to see what is failing exactly:
#$ carbon-cache.py --log-level=debug ...

# Start Graphite daemons
sudo service supervisord restart

# Check via supervisorctl whether the daemons are properly running:
sudo supervisorctl status
# graphite-carbon-cache RUNNING    pid 22058, uptime 0:00:10
# graphite-gunicorn RUNNING    pid 22057, uptime 0:00:10




