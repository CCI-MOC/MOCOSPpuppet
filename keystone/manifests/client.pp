# == Class: keystone::client
#
# Installs Keystone client.
#
# === Parameters
#
# [*ensure*]
#   (optional) Ensure state of the package.
#   Defaults to 'present'.
#
class keystone::client (
  $ensure = 'present'
) {
  if $operatingsystem== 'CentOS' {
    package { 'python2-keystoneclient':
      ensure => $ensure,
      tag    => 'openstack',
    }
  }
  if $operatingsystem== 'RedHat' {
    package { 'python-keystoneclient':
      ensure => $ensure,
      tag    => 'openstack',
    }
  }
}
