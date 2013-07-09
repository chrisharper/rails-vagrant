#
# Cookbook Name:: site_conf
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#
#

template "/etc/nginx/sites-available/#{node['site_conf']['url']}" do 
  source "site_conf.erb"
  mode 00644
end

nginx_site "#{node['site_conf']['url']}" do 
  enable true
end

template "/etc/init.d/#{node['site_conf']['app_name']}_unicorn" do 
  source 'unicorn_conf.erb'
  mode 00755
end

group node['site_conf']['app_name'] do

end

user node['site_conf']['app_name'] do 
  supports :manage_home => true
  home "/home/#{node['site_conf']['app_name']}"
  gid node['site_conf']['app_name']
  shell '/bin/bash'
end

group 'www-data' do 
  members node['site_conf']['app_name']
  append true
  action :manage
end

directory "/home/#{node['site_conf']['app_name']}/.ssh" do
  mode 00700
  owner node['site_conf']['app_name']
  group node['site_conf']['app_name']
  action :create
end

template "/home/#{node['site_conf']['app_name']}/.ssh/authorized_keys" do 
  source 'authorized_keys.erb'
  mode 00644
  owner node['site_conf']['app_name']
  group node['site_conf']['app_name']
end

directory "/var/www" do
  mode 01775
  owner 'www-data'
  group 'www-data'
  action :create
end

postgresql_connection_info = {:host => "127.0.0.1",
                              :port => node['postgresql']['config']['port'],
                              :username => 'postgres',
                              :password => node['postgresql']['password']['postgres']}

postgresql_database node['site_conf']['db_name']  do
    connection postgresql_connection_info
    action :create
end

postgresql_database_user node['site_conf']['db_user'] do 
    connection postgresql_connection_info
    password node['site_conf']['db_password']
    database_name node['site_conf']['db_name']
    privileges [:select,:insert, :update, :delete, :create, :index, :alter,:drop]
    action :create
end
