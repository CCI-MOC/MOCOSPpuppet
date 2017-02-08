# installs ceph from template in modules/moc_openstack/templates
# This is common for both controller and compute
class moc_openstack::install_ceph(
  $ceph_nodes,
  $ceph_endpoints,
  $ceph_user,
  $ceph_vlan,
  $ceph_key,
  $ceph_iface,
  $ceph_net,
  $ceph_netmask) {
  if $::osfamily == 'RedHat' {
    file { "/etc/ceph/":
      ensure => directory,
      owner => root,
      group => root,
      mode => 755,
    } ->
    file { "/etc/ceph/ceph.conf":
      ensure => present,
      owner => root,
      group => root,
      mode => 755,
      content => template('moc_openstack/ceph.conf.erb')
    } ->
    file { "/etc/ceph/client.${ceph_user}.key":
       ensure => present,
       owner => root,
       group => root,
       mode => 755,
       content => template("moc_openstack/client.${ceph_user}.key.erb"),
    } -> 
    file { "/tmp/gen_ceph_intf_file.sh":
       ensure => present,
       owner => root,
       group => root,
       mode => 755,
       content => template('moc_openstack/gen_ceph_intf_file.sh.erb'),
    } ->
    exec{"Creating ceph vlan interface":
     require => File["/tmp/gen_ceph_intf_file.sh"],
     command => "/bin/bash /tmp/gen_ceph_intf_file.sh;ifup ${ceph_iface}.${ceph_vlan};",
     onlyif => "/usr/bin/test ! -f /etc/sysconfig/network-scripts/ifcfg-${ceph_iface}.${ceph_vlan}",
    }
} else {
    fail("The install_missing_package workaround is only supported on RedHat systems!")
  }
}
