class moc_openstack::dnsmasq_neutron (
  $file_path  = '/etc/neutron/dnsmasq-neutron.conf',
  $mtu_config = 'dhcp-option-force=26,9000',
) {

  file {$file_path:
    ensure  => present,
    mode    => '0644',
    owner   => 'neutron',
    group   => 'neutron',
    replace => true,
    content => $mtu_config,
  }
}
