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
# == Class: phabricator::certificates
#
# Sets up SSL certificates for the module.
#
class phabricator::certificates (
  # SSL Certificates.
  $ssl_cert_file           = $phabricator::vars::ssl_cert_file,
  $ssl_cert_file_contents  = $phabricator::vars::ssl_cert_file_contents,
  $ssl_chain_file          = $phabricator::vars::ssl_chain_file,
  $ssl_chain_file_contents = $phabricator::vars::ssl_chain_file_contents,
  $ssl_key_file            = $phabricator::vars::ssl_key_file,
  $ssl_key_file_contents   = $phabricator::vars::ssl_key_file_contents,
) {

  # To use the standard ssl-certs package snakeoil certificate, leave both
  # $ssl_cert_file and $ssl_cert_file_contents empty. To use an existing
  # certificate, specify its path for $ssl_cert_file and leave
  # $ssl_cert_file_contents empty. To manage the certificate with puppet,
  # provide $ssl_cert_file_contents and optionally specify the path to use for
  # it in $ssl_cert_file.
  if ($ssl_cert_file == undef) and ($ssl_cert_file_contents == undef) {
    $cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    if ! defined(Package['ssl-cert']) {
      package { 'ssl-cert':
        ensure => present,
      }
    }
  } else {
    if $ssl_cert_file == undef {
      $cert_file = "/etc/ssl/certs/${::fqdn}.pem"
      if ! defined(File['/etc/ssl/certs']) {
        file { '/etc/ssl/certs':
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          before => File[$cert_file],
        }
      }
    } else {
      $cert_file = $ssl_cert_file
    }
    if $ssl_cert_file_contents != undef {
      file { $cert_file:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => $ssl_cert_file_contents,
      }
    }
  }

  # To avoid using an intermediate certificate chain, leave both
  # $ssl_chain_file and $ssl_chain_file_contents empty. To use an existing
  # chain, specify its path for $ssl_chain_file and leave
  # $ssl_chain_file_contents empty. To manage the chain with puppet, provide
  # $ssl_chain_file_contents and optionally specify the path to use for it in
  # $ssl_chain_file.
  if ($ssl_chain_file == undef) and ($ssl_chain_file_contents == undef) {
    $chain_file = undef
  } else {
    if $ssl_chain_file == undef {
      $chain_file = "/etc/ssl/certs/${::fqdn}_intermediate.pem"
      if ! defined(File['/etc/ssl/certs']) {
        file { '/etc/ssl/certs':
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          before => File[$chain_file],
        }
      }
    } else {
      $chain_file = $ssl_chain_file
    }
    if $ssl_chain_file_contents != undef {
      file { $chain_file:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => $ssl_chain_file_contents,
      }
    }
  }

  # To use the standard ssl-certs package snakeoil key, leave both
  # $ssl_key_file and $ssl_key_file_contents empty. To use an existing key,
  # specify its path for $ssl_key_file and leave $ssl_key_file_contents empty.
  # To manage the key with puppet, provide $ssl_key_file_contents and
  # optionally specify the path to use for it in $ssl_key_file.
  if ($ssl_key_file == undef) and ($ssl_key_file_contents == undef) {
    $key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
    if ! defined(Package['ssl-cert']) {
      package { 'ssl-cert':
        ensure => present,
      }
    }
  } else {
    if $ssl_key_file == undef {
      $key_file = "/etc/ssl/private/${::fqdn}.key"
      if ! defined(File['/etc/ssl/private']) {
        file { '/etc/ssl/private':
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0700',
          before => File[$key_file],
        }
      }
    } else {
      $key_file = $ssl_key_file
    }
    if $ssl_key_file_contents != undef {
      file { $key_file:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        content => $ssl_key_file_contents,
      }
    }
  }

}
