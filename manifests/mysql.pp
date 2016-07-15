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
# == Class: phabricator::mysql
#
# Set up a mysql host for phabricator.
#
class phabricator::mysql(
  $mysql_host              = $phabricator::vars::mysql_host,
  $mysql_port              = $phabricator::vars::mysql_port,
  $mysql_user              = $phabricator::vars::mysql_user,
  $mysql_user_password     = $phabricator::vars::mysql_user_password,
  $mysql_root_password     = $phabricator::vars::mysql_root_password,
) {

  class { '::mysql::server':
    root_password           => $mysql_root_password,
    remove_default_accounts => true,
    override_options        => {
      mysqld => {
        max_allowed_packet      => '32M',
        sql_mode                => 'STRICT_ALL_TABLES',
        ft_stopword_file        => '/opt/phabricator/phabricator/resources/sql/stopwords.txt',
        ft_min_word_len         => 3,
        ft_boolean_syntax       => '\' |-><()~*:""&^\'',
        innodb_buffer_pool_size => '1600M',
      }
    },
  }

  mysql_user { "${mysql_user}@${mysql_host}":
    provider      => 'mysql',
    password_hash => mysql_password($mysql_user_password),
  }

  # Phabricator creates a mess of tables. This ensures that we don't have
  # to create ACL's for all of them.
  mysql_grant { "${mysql_user}@${mysql_host}/phabricator%.*":
    privileges => ['ALL'],
    table      => 'phabricator%.*',
    user       => "${mysql_user}@${mysql_host}",
  }
}
