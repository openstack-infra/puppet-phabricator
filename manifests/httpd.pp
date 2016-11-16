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
# == Class: phabricator::httpd
#
# Set up the virtual host for phabricator.
#
class phabricator::httpd (
  $httpd_vhost        = $phabricator::vars::httpd_vhost,
  $httpd_docroot      = $phabricator::vars::httpd_docroot,
) {
  include ::httpd
  include ::httpd::ssl
  include ::httpd::php

  httpd::mod { 'rewrite':
    ensure => present,
  }

  httpd::mod { 'auth_openid':
    ensure => present,
  }

  # Set up Phabricator as TLS.
  if defined(Class['phabricator::certificates']) {
    ::httpd::vhost { $httpd_vhost:
      port       => 443, # Is required despite not being used.
      docroot    => $httpd_docroot,
      priority   => '50',
      template   => 'phabricator/vhost.erb',
      ssl        => true,
      vhost_name => $httpd_vhost,
    }
  }
}
