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
# == Class: phabricator::vars
#
# Variables, and their defaults, shared between all the submodules. This
# module is used as the source of all the shared default values.
#
class phabricator::vars (
  # Database Configurations.
  $mysql_database          = 'phabricator',
  $mysql_host              = 'localhost',
  $mysql_port              = 3306,
  $mysql_user              = 'phabricator',
  $mysql_user_password,
  $mysql_root_password,

  # Phabricator working directory
  $phabricator_dir        = '/opt/phabricator',

  # SSL Certificates.
  $ssl_cert_file           = undef,
  $ssl_cert_file_contents  = undef, # If left empty puppet will not create file.
  $ssl_chain_file          = undef,
  $ssl_chain_file_contents = undef, # If left empty puppet will not create file.
  $ssl_key_file            = undef,
  $ssl_key_file_contents   = undef, # If left empty puppet will not create file.

  # Virtual host config.
  $httpd_vhost             = $::fqdn,
  $httpd_admin_email       = 'noc@openstack.org',
) {

  # Non-configurable-options (derived)
  $httpd_docroot           = "${phabricator_dir}/phabricator/webroot"
}
