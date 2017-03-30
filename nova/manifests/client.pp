# == Class nova::client
#
# installs nova client
#
# === Parameters:
#
# [*ensure*]
#   (optional) The state for the nova client package
#   Defaults to 'present'
#
class nova::client(
  $ensure = 'present'
) {
  if $operatingsystem== 'CentOS' {
    package { 'python2-novaclient':
      ensure => $ensure,
      tag    => ['openstack'],
    }
  }
  if $operatingsystem== 'RedHat' {
    package { 'python-novaclient':
      ensure => $ensure,
      tag    => ['openstack'],
    }
  }
}
