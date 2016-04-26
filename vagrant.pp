node default {
  class { 'phabricator':
    httpd_vhost         => '192.168.99.10',
    mysql_user_password => 'phabricator',
    mysql_root_password => 'supersecret',
    ssl_cert_file       => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
    ssl_key_file        => "/etc/ssl/private/ssl-cert-snakeoil.key",
  }
}
