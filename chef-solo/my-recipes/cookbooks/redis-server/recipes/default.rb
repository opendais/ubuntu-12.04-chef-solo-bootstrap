#
# Cookbook Name:: redis-server
# Recipe:: default
#
# Copyright 2012, TeamSnap
#
# All rights reserved - Do Not Redistribute
#
#

package "redis-server" do
  action :install
end

execute "disable init script" do
  command "rm -f /etc/rc0.d/K20redis-server /etc/rc1.d/K20redis-server /etc/rc2.d/K80redis-server /etc/rc2.d/S20redis-server /etc/rc3.d/K80redis-server /etc/rc3.d/S20redis-server /etc/rc4.d/K80redis-server /etc/rc4.d/S20redis-server /etc/rc5.d/K80redis-server /etc/rc5.d/S20redis-server /etc/rc6.d/K20redis-server"
  user "root"
end

cookbook_file "/etc/init/redis-server.conf" do
  source "redis-server.conf"
  mode 0644
  owner "root"
  group "root"
end

template "/etc/redis/redis.conf" do
  source "redis.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, "service[redis-server]"
end

service "redis-server" do
  action :enable
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
end
