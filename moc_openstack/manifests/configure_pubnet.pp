class moc_openstack::configure_pubnet($pub_iface, $pub_vlan, $pub_net, $pub_netmask) {
  file { "/tmp/gen_pub_intf_file.sh":
    ensure => present,
    owner => root,
    group => root,
    mode => 755,
    content => template('moc_openstack/gen_pub_intf_file.sh.erb'),
  } ->
  exec{"Creating public vlan interface":
    require => File["/tmp/gen_pub_intf_file.sh"],
    command => "/bin/bash /tmp/gen_pub_intf_file.sh;ifup ${pub_iface}.${pub_vlan};",
    onlyif => "/usr/bin/test ! -f /etc/sysconfig/network-scripts/ifcfg-${pub_iface}.${pub_vlan}",
  }
}
