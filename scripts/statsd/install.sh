#!/bin/bash

NODE_VERSION="v0.10.28"
NODE_FILENAME="node-$NODE_VERSION-linux-x64"
PARENT_LOCATION="/opt/nodejs"

###
### Prerequisive ###
###
yum -y update
yum -y groupinstall "Development Tools"

sudo mkdir -p /usr/local/src
sudo cp etc/statsd.init /usr/local/src

###
### Install NodeJS ###
###

### Download NodeJS ###
cd /usr/local/src
sudo wget -nc http://nodejs.org/dist/$NODE_VERSION/$NODE_FILENAME.tar.gz
#wget -E -H -k -K -p http://<site>/<document>
sudo tar zxvf $NODE_FILENAME.tar.gz
sudo mkdir -p $PARENT_LOCATION
sudo mv $NODE_FILENAME $PARENT_LOCATION/

### Link binary files ###
rm -f /usr/local/bin/node
rm -f /usr/local/bin/npm
sudo ln -s $PARENT_LOCATION/$NODE_FILENAME/bin/node /usr/local/bin
sudo ln -s $PARENT_LOCATION/$NODE_FILENAME/bin/npm /usr/local/bin

###
### Install StatsD ###
###

### Download StatsD ###
cd /usr/local/src
sudo git clone https://github.com/etsy/statsd.git
sudo mv statsd $PARENT_LOCATION/
sudo cp $PARENT_LOCATION/statsd/exampleConfig.js $PARENT_LOCATION/statsd/config.js
### Install node-supervisor ###
#sudo npm install supervisor -g

### Install Supervisord ###
sudo rpm -Uhv https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum -y install supervisor
sudo chkconfig supervisord on
sudo chmod 600 /etc/supervisord.conf

### Configure Supervisord ###
sudo cat statsd.init >> /etc/supervisord.conf
sudo mkdir -p /var/log/nodejs
sudo rm -f statsd.init
###
### Run StatsD ###
###
sudo service supervisord restart

