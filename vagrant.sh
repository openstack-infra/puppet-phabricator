#!/usr/bin/env bash

# Install Puppet!
if [ ! -f /etc/apt/sources.list.d/puppetlabs.list ]; then
  lsbdistcodename=`lsb_release -c -s`
  wget https://apt.puppetlabs.com/puppetlabs-release-${lsbdistcodename}.deb
  sudo dpkg -i puppetlabs-release-${lsbdistcodename}.deb
  sudo apt-get update
  sudo apt-get dist-upgrade -y
fi

apt-get install git -y

if [ ! -d /etc/puppet/modules/httpd ]; then
   git clone git://git.openstack.org/openstack-infra/puppet-httpd /etc/puppet/modules/httpd
fi
if [ ! -d /etc/puppet/modules/firewall ]; then
  puppet module install puppetlabs-firewall --version 1.1.3
fi
if [ ! -d /etc/puppet/modules/mysql ]; then
  puppet module install puppetlabs-mysql --version 3.6.2
fi
if [ ! -d /etc/puppet/modules/inifile ]; then
  puppet module install puppetlabs-inifile --version 1.1.3
fi
if [ ! -d /etc/puppet/modules/vcsrepo ]; then
  puppet module install openstackci-vcsrepo --version 0.0.8
fi

# Symlink the module
if [ ! -d /etc/puppet/modules/phabricator ]; then
  sudo ln -s /vagrant /etc/puppet/modules/phabricator
fi
