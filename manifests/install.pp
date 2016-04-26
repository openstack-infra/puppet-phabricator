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
# == Class: phabricator::install
#
# Installation of phabricator itself.
#
class phabricator::install (
  $phabricator_dir         = $phabricator::config::phabricator_dir,
  $mysql_database          = $phabricator::config::mysql_database,
  $mysql_host              = $phabricator::config::mysql_host,
  $mysql_port              = $phabricator::config::mysql_port,
  $mysql_user              = $phabricator::config::mysql_user,
  $mysql_user_password     = $phabricator::config::mysql_user_password,
  $httpd_vhost             = $phabricator::config::httpd_vhost,
) {

  # Dependencies
  package { [
    'php5',
    'php5-mysql',
    'php5-gd',
    'php5-dev',
    'php5-curl',
    'php-apc',
    'php5-cli',
    'php5-json',
    'sendmail',
    'python-pygments']:
    ensure => present,
  }
  if !defined(Package['git']) {
    package { 'git':
      ensure => present
    }
  }

  ini_setting { 'Increase post_max_size in php.ini':
    ensure  => present,
    path    => '/etc/php5/apache2/php.ini',
    section => 'PHP',
    setting => 'post_max_size',
    value   => '32M',
    notify  => Service['httpd'],
  }
  ini_setting { 'Set opcache.validate_timestamps in php.ini':
    ensure  => present,
    path    => '/etc/php5/apache2/php.ini',
    section => 'opcache',
    setting => 'opcache.validate_timestamps',
    value   => '0',
    notify  => Service['httpd'],
  }

  file { [$phabricator_dir, "${phabricator_dir}/repo"]:
    ensure => directory,
  }

  vcsrepo { "${phabricator_dir}/phabricator":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/phacility/phabricator.git',
    revision => 'stable',
    require  => [
      File[$phabricator_dir],
      Package['git'],
    ]
  }

  vcsrepo { "${phabricator_dir}/arcanist":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/phacility/arcanist.git',
    revision => 'stable',
    require  => [
      File[$phabricator_dir],
      Package['git'],
    ]
  }

  vcsrepo { "${phabricator_dir}/libphutil":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/phacility/libphutil.git',
    revision => 'stable',
    require  => [
      File[$phabricator_dir],
      Package['git'],
    ]
  }

  file { 'local.json':
    ensure  => present,
    path    => "${phabricator_dir}/phabricator/conf/local/local.json",
    content => template('phabricator/local.json.erb'),
    require => Vcsrepo["${phabricator_dir}/phabricator"],
    notify  => Service['httpd'],
  }

  exec { 'load-initial-db':
    command => "${phabricator_dir}/phabricator/bin/storage upgrade --force",
    unless  => "${phabricator_dir}/phabricator/bin/storage status",
    require => [
      Vcsrepo["${phabricator_dir}/phabricator"],
      Vcsrepo["${phabricator_dir}/libphutil"],
      Vcsrepo["${phabricator_dir}/arcanist"],
    ]
  }

  exec { 'Ensure daemons are running':
    command   => "${phabricator_dir}/phabricator/bin/phd restart",
    unless    => "${phabricator_dir}/phabricator/bin/phd status",
    subscribe => Vcsrepo["${phabricator_dir}/libphutil"],
    require   => [
      Exec['load-initial-db'],
      File['local.json'],
    ]
  }
}
