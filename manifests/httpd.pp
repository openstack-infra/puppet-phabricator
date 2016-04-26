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
	$ssl_cert_file      = $phabricator::config::ssl_cert_file,
	$ssl_chain_file     = $phabricator::config::ssl_chain_file,
	$ssl_key_file       = $phabricator::config::ssl_key_file,
	$httpd_vhost        = $phabricator::config::httpd_vhost,
	$httpd_admin_email  = $phabricator::config::httpd_admin_email,
	$httpd_docroot      = $phabricator::config::httpd_docroot,
) {
	include ::httpd
	include ::httpd::ssl
	include ::httpd::php

	httpd_mod { 'rewrite':
		ensure => present,
	}

	::httpd::vhost { $httpd_vhost:
		port     => 443,
		docroot  => $httpd_docroot,
		priority => '50',
		template => 'phabricator/vhost.erb',
		ssl      => true,
	}
}
