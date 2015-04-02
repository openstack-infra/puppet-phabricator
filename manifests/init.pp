# == Class: phabricator
#
class phabricator (
  $vhost_name           = $::fqdn,
  $phab_dir             = '/phabricator',
  $instance             = 'dev',
  $mysql_host           = 'localhost',
  $mysql_port           = 3306,
  $mysql_database       = 'phabricator',
  $mysql_user           = 'phabricator',
  $mysql_user_password,
  $ssl_cert_file = "/etc/ssl/certs/${::fqdn}.pem",
  $ssl_key_file = "/etc/ssl/private/${::fqdn}.key",
  $ssl_chain_file = '',
  $ssl_cert_file_contents = '', # If left empty puppet will not create file.
  $ssl_key_file_contents = '',  # If left empty puppet will not create file.
  $ssl_chain_file_contents = '' # If left empty puppet will not create file.
) {

  $instances_dir = "${phab_dir}/instances"
  $instance_dir = "${instances_dir}/${instance}"

  $packages = [
    'php5',
    'php5-mysql',
    'php5-gd',
    'php5-dev',
    'php5-curl',
    'php-apc',
    'php5-cli'
  ]
  package { $packages:
    ensure => installed,
  }

  if !defined(Package['git']) {
    package { 'git':
      ensure => present
    }
  }

  file { $phab_dir:
    ensure => directory,
  }
  file { $instances_dir:
    ensure => directory,
  }
  file { $instance_dir:
    ensure => directory,
  }

  if $ssl_cert_file_contents != '' {
    file { $ssl_cert_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_cert_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  if $ssl_key_file_contents != '' {
    file { $ssl_key_file:
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      content => $ssl_key_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  if $ssl_chain_file_contents != '' {
    file { $ssl_chain_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_chain_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  vcsrepo { "${instance_dir}/phabricator":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/phacility/phabricator.git',
    require  => [
      File[$instance_dir],
      Package['git'],
    ]
  }

  vcsrepo { "${instance_dir}/arcanist":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/phacility/arcanist.git',
    require  => [
      File[$instance_dir],
      Package['git'],
    ]
  }

  vcsrepo { "${instance_dir}/libphutil":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/phacility/libphutil.git',
    require  => [
      File[$instance_dir],
      Package['git'],
    ]
  }

  file { 'initial.db':
    ensure => present,
    path   => "${phab_dir}/initial.db",
    source => 'puppet:///modules/phabricator/initial.db',
  }

  file {'local.json':
    ensure  => present,
    path    => "${instance_dir}/phabricator/conf/local/local.json",
    content => template('phabricator/local.json.erb'),
  }

  exec { 'load-initial-db':
    command     => "mysql < ${phab_dir}/initial.db && ${instance_dir}/phabricator/bin/storage upgrade --force",
    unless      => "${instance_dir}/phabricator/bin/storage status",
    subscribe   => File['initial.db'],
    refreshonly => true,
    require     => [
                    Vcsrepo["${instance_dir}/phabricator"],
                    File['initial.db'],
                    ]
  }

  exec { 'update-database':
    command     => "${instance_dir}/phabricator/bin/storage upgrade --force",
    refreshonly => true,
    subscribe   => Vcsrepo["${instance_dir}/phabricator"],
    require     => Vcsrepo["${instance_dir}/phabricator"],
  }

  include apache
  a2mod { 'rewrite':
    ensure => present,
  }

  apache::vhost { $vhost_name:
    port     => 443,
    docroot  => "${instance_dir}/phabricator/webroot",
    priority => '50',
    template => 'phabricator/vhost.erb',
    ssl      => true,
  }

}
