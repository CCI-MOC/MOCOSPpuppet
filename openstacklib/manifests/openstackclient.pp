# == Class: openstacklib::openstackclient
#
# Installs the openstackclient
#
# == Parameters
#
#  [*package_ensure*]
#    Ensure state of the openstackclient package.
#    Optional. Defaults to 'present'.
#
class openstacklib::openstackclient(
  $package_ensure = 'latest',
){
    if $operatingsystem== 'CentOS' {$osclient_package_name = 'python2-openstackclient'} else {$osclient_package_name = 'python-openstackclient'}
    package { $osclient_package_name:
    ensure => $package_ensure,
    tag    => 'openstack',
  }
}
