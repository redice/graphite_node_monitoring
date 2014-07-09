#!/bin/bash
sudo yum install -y httpd-devel pcre perl pcre-devel zlib zlib-devel GeoIP GeoIP-devel openssl openssl-devel
sudo yum install -y zlib-devel wget openssl-devel pcre pcre-devel make gcc gcc-c++ curl-devel

sudo yum -y install gcc g++ make automake autoconf
sudo yum -y install sysstat w3m lynx
sudo yum -y install curl openssl

### Install collectd
mkdir -p /usr/local/src
#cp collectd/etc/collectd.conf /usr/local/src/
cd /usr/local/src
# Download collectd soruce
sudo wget -nc --no-check-certificate https://collectd.org/files/collectd-5.4.1.tar.gz
sudo tar zxvf collectd-5.4.1.tar.gz
cd collectd-5.4.1
# Compile collectd
#sudo ./configure --enable-all-plugins
sudo make clean
sudo ./configure \
	JAVA_CPPFLAGS="-I$JAVA_HOME/include -I$JAVA_HOME/include/linux" \
	JAVA_LDFLAGS="-ljvm" \
	--enable-curl=force \
	--enable-network=force \
	--enable-syslog=force \
	--enable-logfile=force \
	--enable-nginx=force \
	--enable-write_graphite=force \
	--disable-ipvs \
	--with-java=$JAVA_HOME \
	--enable-java=force
	
sudo make && sudo make install
# Copy collectd service init script
cp contrib/redhat/init.d-collectd /etc/init.d/collectd
sudo chmod 755 /etc/init.d/collectd

# Link run binary
sudo ln -s /opt/collectd/sbin/collectd /usr/sbin/collectd
sudo ln -s /opt/collectd/sbin/collectdmon /usr/sbin/collectdmon
# Link configuration file
#sudo mv -f /usr/local/src/collectd.conf /opt/collectd/etc/collectd.conf
sudo ln -s /opt/collectd/etc/collectd.conf /etc/collectd.conf

#Enable system service
sudo chkconfig --add collectd
sudo chkconfig collectd on
