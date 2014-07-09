#!/bin/sh

## First we install httpd-devel, pcre, pcre-devel, zlib, zlib-devel, perl, geoip and geoip-devel packages like this:
sudo yum install -y httpd-devel pcre perl pcre-devel zlib zlib-devel GeoIP GeoIP-devel openssl openssl-devel
sudo yum install -y zlib-devel wget openssl-devel pcre pcre-devel make gcc gcc-c++ curl-devel

mkdir -p /usr/local/src/
sudo cp initscript logrotatescript /usr/local/src/
cd /usr/local/src/

### Update Logrotate ###
sudo wget -nc http://ftp.de.debian.org/debian/pool/main/l/logrotate/logrotate_3.8.7.orig.tar.gz
sudo tar zxvf logrotate_3.8.7.orig.tar.gz
cd logrotate-3.8.7
sudo make && sudo make install

###  Download Nginx package ###
sudo wget -nc http://nginx.org/download/nginx-1.4.7.tar.gz
sudo tar zxvf nginx-1.4.7.tar.gz

### Download module ###
# session sticky
sudo wget -nc --no-check-certificate https://nginx-sticky-module.googlecode.com/files/nginx-sticky-module-1.1.tar.gz
sudo tar zxvf nginx-sticky-module-1.1.tar.gz
# cache
sudo wget -nc http://labs.frickle.com/files/ngx_cache_purge-2.1.tar.gz
sudo tar zxvf ngx_cache_purge-2.1.tar.gz
# echo
sudo wget -nc https://github.com/agentzh/echo-nginx-module/archive/v0.51.tar.gz -O echo-nginx-module-0.51.tar.gz
sudo tar zxvf echo-nginx-module-0.51.tar.gz
# openssl 1.0.x, install OpenSSL manually
sudo wget -nc https://www.openssl.org/source/openssl-1.0.1f.tar.gz
sudo tar zxvf openssl-1.0.1f.tar.gz
sudo cd openssl-1.0.1f
sudo ./config
sudo make && sudo make install

### compile ###
cd nginx-1.4.7
sudo ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --add-module=../nginx-sticky-module-1.1 --add-module=../ngx_cache_purge-2.1 --add-module=../echo-nginx-module-0.51 --with-openssl=../openssl-1.0.1f

sudo make && sudo make install
sudo useradd -M -r -s /sbin/nologin -d /var/lib/nginx nginx 
sudo mkdir -p /var/log/nginx
sudo chown nginx:root /var/log/nginx

# setup init script
cd /usr/local/src/
sudo mv initscript /etc/init.d/nginx
sudo chmod 755 /etc/init.d/nginx
#set rotate log
sudo mv logrotatescript /etc/logrotate.d/nginx

### Configure Nginx 
sudo mkdir -p /usr/local/nginx/cache