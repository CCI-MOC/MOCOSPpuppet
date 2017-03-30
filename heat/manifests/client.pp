# == Class: heat::client
#
# Installs the heat python library.
#
# === Parameters
#
# [*ensure*]
#   (Optional) Ensure state for package.
#
class heat::client (
  $ensure = 'present'
) {

  include ::heat::params

  if $operatingsystem== 'CentOS' {
    package { 'python2-heatclient':
      ensure => $ensure,
      name   => $::heat::params::client_package_name,
      tag    => 'openstack',
    }
  }
  if $operatingsystem== 'RedHat' {
    package { 'python2-heatclient':
      ensure => $ensure,
      name   => $::heat::params::client_package_name,
      tag    => 'openstack',
    }
  }
}
