class moc_openstack::configure_privnet($priv_iface, $priv_net, $priv_netmask) {
  file { "/tmp/gen_priv_intf_file.sh":
    ensure => present,
    owner => root,
    group => root,
    mode => 755,
    content => template('moc_openstack/gen_priv_intf_file.sh.erb'),
  } ->
  exec{"Creating private interface":
    require => File["/tmp/gen_priv_intf_file.sh"],
    command => "/bin/bash /tmp/gen_priv_intf_file.sh;ifup ${priv_iface};",
#    before => Class['hosts'],
#    onlyif => "/usr/bin/test ! -f /etc/sysconfig/network-scripts/ifcfg-${priv_iface}",
  }
}
