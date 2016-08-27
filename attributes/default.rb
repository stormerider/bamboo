#
# Cookbook Name:: bamboo
# Attributes:: default
#
# Author:: Ramon Makkelie, Stephan Oudmaijer
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

# bamboo server
default[:bamboo][:url]                            = 'http://localhost'                  # bamboo server URL
default[:bamboo][:home_dir]                       = '/opt/bamboo'                       # bamboo installation directory
default[:bamboo][:data_dir]                       = '/var/bamboo'                       # bamboo data directory
default[:bamboo][:user]                           = 'bamboo'                            # bamboo user
default[:bamboo][:group]                          = 'bamboo'                            # bamboo group
default[:bamboo][:user_home]                      = '/home/bamboo'                      # bamboo system user home directory
default[:bamboo][:name]                           = 'bamboo'                            # bamboo application/service name
default[:bamboo][:version]                        = '5.12.2'
default[:bamboo][:download_url]                   = "http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-#{node[:bamboo][:version]}.tar.gz"
default[:bamboo][:checksum] =
  case node[:bamboo][:version]
  when '5.10.3' then 'da6326d49dd5234319518f4b55fdfe521918931971c48bd43a48d6f6fb2717a6'
  when '5.12.3.1' then '012d40a06aeda188ccd9d84d5b520d51e92dfd5ef081d1a8a8e9a9f333e01a5b'
  end

default[:bamboo][:database][:external]            = false
default[:bamboo][:database][:type]                = 'postgresql'
case node[:bamboo][:database][:type]
when 'mysql'
  default[:bamboo][:database][:version]           = '5.6'
  default[:bamboo][:database][:host]              = '127.0.0.1'
  default[:bamboo][:database][:port]              = 3306
  default[:bamboo][:database][:root_user_name]    = 'root'
  default[:bamboo][:database_type]                = 'MySQL'
when 'postgresql'
  default[:postgresql][:version]                  = '9.4'
  default[:postgresql][:dir]                      = '/etc/postgresql/9.4/main'
  default[:postgresql][:client][:packages]        = ['postgresql-client-9.4', 'libpq-dev']
  default[:postgresql][:server][:packages]        = ['postgresql-9.4']
  default[:postgresql][:contrib][:packages]       = ['postgresql-contrib-9.4']
  default[:bamboo][:database][:host]              = 'localhost'
  default[:bamboo][:database][:port]              = 5432
  default[:postgresql][:config_pgtune][:db_type]  = 'web'
  default[:bamboo][:database][:root_user_name]    = 'postgres'
  default[:bamboo][:database_type]                = 'PostgreSQL'
end
default[:bamboo][:database][:name]                = 'bamboo'
default[:bamboo][:database][:user]                = 'bamboo'
default[:bamboo][:database][:password]            = 'bamboo'
default[:mysql][:server_root_password]            = 'changeme'
default[:postgresql][:password][:postgres]        = 'changeme'

default[:bamboo][:jvm][:minimum_memory]           = '512m'
default[:bamboo][:jvm][:maximum_memory]           = '2048m'
default[:bamboo][:jvm][:maximum_permgen]          = '256m'
default[:bamboo][:jvm][:support_args]             = ''

default[:bamboo][:catalina][:opts]                = ''

default[:java][:install_flavor]                   = 'openjdk'
default[:java][:jdk_version]                      = '8'

# bamboo agent
default[:bamboo][:agent][:home_dir]               = '/opt/bamboo'                       # bamboo installation directory
default[:bamboo][:agent][:data_dir]               = '/var/bamboo'                       # bamboo data directory
default[:bamboo][:agent][:user]                   = 'bamboo'                            # bamboo user
default[:bamboo][:agent][:group]                  = 'bamboo'                            # bamboo group
default[:bamboo][:agent][:user_home]              = '/home/bamboo'                      # bamboo system user home directory
default[:bamboo][:agent][:disable_agent_auto_capability_detection] = true
default[:bamboo][:agent][:additional_path]        = ''
default[:bamboo][:agent_capabilities]             = {}

# If you're authenticating against a Crowd server you can use this authenticator for single sign-on.
# Enable it after configuring your Crowd properties through user management and restart Bamboo. It does not support
# Crowd property changes at runtime. If you need to switch back to local users, revert the change and
# restart Bamboo again.
default[:bamboo][:crowd]                          = false

# graylog2 integrations
default[:bamboo][:graylog][:enabled]              = false
default[:bamboo][:graylog][:facility]             = 'bamboo'
default[:bamboo][:graylog][:host]                 = 'change_me'
default[:bamboo][:graylog][:origin]               = node[:fqdn]

# backup to an s3 bucket
default[:bamboo][:backup][:ceph]                  = false
default[:bamboo][:backup][:enabled]               = false
default[:bamboo][:backup][:s3_host]               = 's3.amazonaws.com'
default[:bamboo][:backup][:s3_scheme]             = 'http'
default[:bamboo][:backup][:s3_port]               = 80
default[:bamboo][:backup][:s3_access_key_id]      = 'change_me'
default[:bamboo][:backup][:s3_secret_access_key]  = 'change_me'
default[:bamboo][:backup][:s3_bucket]             = 'change_me'
default[:bamboo][:backup][:hour]                  = '1'
default[:bamboo][:backup][:minute]                = '*'

# damn postgresql:ruby recipe still builds at compile time
default[:apt][:compile_time_update] = true
default['build-essential']['compile_time'] = true
