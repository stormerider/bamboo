#
# Cookbook Name:: chef-client
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
if (node[:bamboo][:external_data])
  directory "/mnt/data" do
    owner  "root"
    group  "root"
    mode "0775"
    action :create
  end
  mount "/mnt/data" do
    device "/dev/vdc1"
    fstype "ext4"
  end
end

include_recipe "java"

# create bamboo service
service "bamboo" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
end

# download bamboo

remote_file "/opt/atlassian-bamboo-#{node['bamboo']['version']}.tar.gz" do
  source "#{node['bamboo']['download_url']}"
  mode "0644"
  owner  node[:bamboo][:user]
  group  node[:bamboo][:group]
  not_if { ::File.exists?("/opt/atlassian-bamboo-#{node['bamboo']['version']}.tar.gz") }
end

# create dir releases
execute "tar -xvzf /opt/atlassian-bamboo-#{node['bamboo']['version']}.tar.gz -C /opt/" do
  user  node[:bamboo][:user]
  group  node[:bamboo][:group]
  notifies :stop, resources(:service => "bamboo")
  not_if { ::File.directory?("/opt/atlassian-bamboo-#{node['bamboo']['version']}/") }
end

# symlink from deployed release to current
# create dir bamboo/current
link "/opt/bamboo" do
  to "/opt/atlassian-bamboo-#{node['bamboo']['version']}"
end

# COMMENTED OUT BECAUSE WRAPPER IS BROKEN
# make symlink from wrapper/start-bamboo to /etc/init.d/bamboo
# add start service at system start
#link "/etc/init.d/bamboo" do
#  to "/opt/bamboo/wrapper/start-bamboo"
#end


# insert jdbc mysql database_mysql.rb
#if (node[:bamboo][:mysql])
#   remote_file "/opt/bamboo/wrapper/lib/mysql_connector_java-#{node['bamboo']['mysql_connector_version']}.jar" do
#     source "http://repo1.maven.org/maven2/mysql/mysql-connector-java/#{node['bamboo']['mysql_connector_version']}/mysql-connector-java-#{node['bamboo']['mysql_connector_version']}.jar"
#     mode "0644"
#     not_if { ::File.exists?("/opt/bamboo/wrapper/lib/mysql-connector-java-#{node['bamboo']['mysql_connector_version']}.jar") }
#   end
#end

if (node[:bamboo][:mysql])
  directory "/opt/bamboo/lib" do
    owner  node[:bamboo][:user]
    group  node[:bamboo][:group]
    mode "0775"
    action :create
  end
  remote_file "/opt/bamboo/lib/mysql_connector_java-#{node['bamboo']['mysql_connector_version']}.jar" do
    source "http://repo1.maven.org/maven2/mysql/mysql-connector-java/#{node['bamboo']['mysql_connector_version']}/mysql-connector-java-#{node['bamboo']['mysql_connector_version']}.jar"
    mode "0644"
    owner  node[:bamboo][:user]
    group  node[:bamboo][:group]
    not_if { ::File.exists?("/opt/bamboo/wrapper/lib/mysql-connector-java-#{node['bamboo']['mysql_connector_version']}.jar") }
  end
end


template "bamboo.upstart.conf" do
  path "/etc/init/bamboo.conf"
  source "bamboo.upstart.conf.erb"
  owner  node[:bamboo][:user]
  group  node[:bamboo][:group]
  mode "0644"
  notifies :restart, resources(:service => "bamboo")
end

template "bamboo-init.properties" do
  path "/opt/bamboo/webapp/WEB-INF/classes/bamboo-init.properties"
  source "bamboo-init.properties.erb"
  owner  node[:bamboo][:user]
  group  node[:bamboo][:group]
  mode 0644
  variables({
         "bamboo_home" => node['bamboo']['bamboo_home']
            })
  notifies :restart, resources(:service => "bamboo")
end

template "wrapper.conf" do
  path "/opt/bamboo/conf/wrapper.conf"
  source "wrapper.conf.erb"
  owner  node[:bamboo][:user]
  group  node[:bamboo][:group]
  mode 0644
  variables({
         "port" => node['bamboo']['port'],
         "xms" => node['bamboo']['xms'],
         "xmx" => node['bamboo']['xmx'],
         "permsize" => node['bamboo']['permsize']
            })
  notifies :restart, resources(:service => "bamboo")
end

service "bamboo" do
  action [:enable, :start]
end

# link logs to logical location
# this is because we use upstart + console option
link "/opt/bamboo/logs/bamboo.log" do
  to "/var/log/upstart/bamboo.log"
end

#package "ruby1.9.1-dev" do
#  action :install
#end
#needed for nokogiri
package "libxml2-dev" do
  action :install
end

package "libxslt-dev" do
  action :install
end

include_recipe "backup"

backup_install node[:name]
backup_generate_config node[:name]
gem_package "fog" do
  version "> 1.9.0"
end
backup_generate_model "mysql" do
  description "Our shard"
  backup_type "database"
  database_type "MySQL"
  store_with({"engine" => "Local", "settings" => { "local.path" => "/opt/backup", "local.keep" => "5", } } )
  #store_with({"engine" => "S3", "settings" => { "s3.access_key_id" => "1c6c6f540fba4f3fa62dc69233a454f2", "s3.secret_access_key" => "370d72a9aba54e66bbc2fdf110e06e08", "s3.provider" => "http://s3.eden.klm.com/", "s3.region" => "", "s3.bucket" => "sample", "s3.path" => "/", "s3.keep" => 10 } } )
  options({"db.host" => "\"localhost\"", "db.username" => "\"#{node['bamboo']['jdbc_username']}\"", "db.password" => "\"#{node['bamboo']['jdbc_password']}\"", "db.name" => "\"bamboo\""})
  action :backup
end
