#!/usr/bin/env bash
# Ubuntu 12.04 LTS - Bootstrap default, install better text editor, nmap, and chef-solo :P
# Refer to install.sh for the actual install.
apt-get -y update
apt-get -y install vim build-essential nmap zlib1g-dev libssl-dev libreadline6-dev libyaml-dev

cd /tmp
wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
tar -xvzf ruby-1.9.3-p194.tar.gz
cd ruby-1.9.3-p194/
./configure --prefix=/usr/local
make
make install
#apt-get install -y ruby rubygems

gem install ruby-shadow --no-ri --no-rdoc
gem install chef --no-ri --no-rdoc -v 11.4.4

