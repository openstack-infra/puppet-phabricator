# Copyright 2014 Hewlett-Packard Development Company, L.P.
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
class phabricator::mysql(
  $mysql_root_password,
  $mysql_bind_address = '127.0.0.1',
  $mysql_port         = '3306'
  ) {

    class { '::mysql::server':
      config_hash => {
        'root_password'  => $mysql_root_password,
        'default_engine' => 'InnoDB',
        'bind_address'   => $mysql_bind_address,
        'port'           => $mysql_port,
        }
    }

    mysql::server::config { 'phab_config':
      settings => {
        'mysqld' => {
          'max_allowed_packet'      => '32M',
          'sql_mode'                => 'STRICT_ALL_TABLES',
          'ft_stopword_file'        => '/phabricator/instances/dev/phabricator/resources/sql/stopwords.txt',
          'ft_min_word_len'         => '3',
          'ft_boolean_syntax'       => '\' |-><()~*:""&^\'',
          'innodb_buffer_pool_size' => '1600M',
        }
      }
    }
  }
