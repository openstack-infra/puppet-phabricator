# Copyright 2016 Hewlett Packard Enterprise Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: phabricator
#
# Set up a full, standalone instance of phabricator.
#
class phabricator (
  # Database Configurations.
  $mysql_user_password,
  $mysql_root_password,
  $mysql_database          = 'phabricator',
  $mysql_host              = 'localhost',
  $mysql_port              = 3306,
  $mysql_user              = 'phabricator',

  # Phabricator working directory
  $phabricator_dir         = '/opt/phabricator',

  # OpenID configuration
  $auth_location = '/auth/login/RemoteUser:self/',
  $authopenidsingleidp = 'https://openstackid.org/',

  # SSL Certificates.
  $ssl_cert_file           = undef,
  $ssl_cert_file_contents  = undef, # If left empty puppet will not create file.
  $ssl_chain_file          = undef,
  $ssl_chain_file_contents = undef, # If left empty puppet will not create file.
  $ssl_key_file            = undef,
  $ssl_key_file_contents   = undef, # If left empty puppet will not create file.

  # Httpd config.
  $httpd_vhost             = $::fqdn,
  $httpd_admin_email       = "webmaster@${::fqdn}",
) {

  # Set up the shared configuration.
  class { '::phabricator::vars':
    mysql_database          => $mysql_database,
    mysql_host              => $mysql_host,
    mysql_port              => $mysql_port,
    mysql_user              => $mysql_user,
    mysql_user_password     => $mysql_user_password,
    mysql_root_password     => $mysql_root_password,
    phabricator_dir         => $phabricator_dir,
    ssl_cert_file           => $ssl_cert_file,
    ssl_cert_file_contents  => $ssl_cert_file_contents,
    ssl_chain_file          => $ssl_chain_file,
    ssl_chain_file_contents => $ssl_chain_file_contents,
    ssl_key_file            => $ssl_key_file,
    ssl_key_file_contents   => $ssl_key_file_contents,
    httpd_vhost             => $httpd_vhost,
    httpd_admin_email       => $httpd_admin_email,

    before                  => [
      Class['Phabricator::Certificates'],
      Class['Phabricator::Httpd'],
      Class['Phabricator::Mysql'],
      Class['Phabricator::Install'],
    ]
  }

  include ::phabricator::certificates
  include ::phabricator::mysql

  class { '::phabricator::httpd':
    require => [
      Class['phabricator::install'],
      Class['phabricator::mysql'],
      Class['phabricator::certificates']
    ]
  }

  class { '::phabricator::install':
    require => [
      Class['phabricator::mysql'],
    ]
  }
}
