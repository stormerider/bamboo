name             'bamboo'
maintainer       'Ramon Makkelie, Stephan Oudmaijer'
maintainer_email 'ramonmakkelie@gmail.com, soudmaijer@gmail.com'
license          'Apache 2.0'
description      'Installs and configures Bamboo'
version          '1.7.0'
issues_url       'https://github.com/ramonskie/bamboo/issues' if respond_to?(:issues_url)
source_url       'https://github.com/ramonskie/bamboo.git' if respond_to?(:source_url)

recipe 'bamboo::default',     'Installs the bamboo server with optional backup in place and logging to graylog.'
recipe 'bamboo::server',      'Only installs the bamboo server.'
recipe 'bamboo::agent',       'Installs a bamboo agent.'

# We only test on ubuntu, so debian and ubuntu should be rather safe
%w(debian ubuntu centos redhat amazon).each do |os|
  supports os
end

# Always specify the version of your dependencies
depends 'apt'
depends 'ark'
depends 'apache2'
depends 'cron'
depends 'backup' #,          '= 0.3.0'
depends 'database',        '~> 4.0'
depends 'git'
depends 'java'
depends 'mysql'
depends 'mysql_connector', '~> 0.7'
depends 'perl'
depends 'mysql2_chef_gem', '~> 1.0'
depends 'postgresql',      '~> 4.0.6'
depends 'build-essential'
