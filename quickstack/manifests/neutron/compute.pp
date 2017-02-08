# Quickstack compute node configuration for neutron (OpenStack Networking)
class quickstack::neutron::compute (
  $agent_type                   = 'ovs',
  $auth_host                    = $quickstack::params::controller_pub_host,
  $ceilometer                   = 'false',
  $ceilometer_metering_secret   = $quickstack::params::ceilometer_metering_secret,
  $ceilometer_user_password     = $quickstack::params::ceilometer_user_password,
  $manage_ceph_conf             = true,
  $ceph_cluster_network         = '',
  $ceph_public_network          = '',
  $ceph_fsid                    = '',
  $ceph_images_key              = '',
  $ceph_volumes_key             = '',
  $ceph_rgw_key                 = '',
  $ceph_mon_host                = [ ],
  $ceph_mon_initial_members     = [ ],
  $ceph_conf_include_osd_global = true,
  $ceph_osd_pool_size           = '',
  $ceph_osd_journal_size        = '',
  $ceph_osd_mkfs_options_xfs    = '-f -i size=2048 -n size=64k',
  $ceph_osd_mount_options_xfs   = 'inode64,noatime,logbsize=256k',
  $ceph_conf_include_rgw        = false,
  $ceph_rgw_hostnames           = [ ],
  $ceph_extra_conf_lines        = [ ],
  $cinder_backend_gluster       = $quickstack::params::cinder_backend_gluster,
  $cinder_backend_nfs           = 'false',
  $cinder_backend_rbd           = $quickstack::params::cinder_backend_rbd,
  $cinder_catalog_info          = 'volume:cinder:internalURL',
  $glance_backend_rbd           = 'true',
  $glance_host                  = $quickstack::params::controller_pub_host,
  $nova_host                    = $quickstack::params::controller_pub_host,
  $enable_tunneling             = $quickstack::params::enable_tunneling,
  $mysql_host                   = $quickstack::params::mysql_host,
  $neutron_db_user              = 'neutron',
  $neutron_db_dbname            = 'neutron',
  $neutron_db_password          = $quickstack::params::neutron_db_password,
  $neutron_user_password        = $quickstack::params::neutron_user_password,
  $neutron_host                 = $quickstack::params::controller_pub_host,
  $enable_tunneling             = $quickstack::params::enable_tunneling,
  $nova_db_password             = $quickstack::params::nova_db_password,
  $nova_user_password           = $quickstack::params::nova_user_password,
  $ovs_bridge_mappings          = $quickstack::params::ovs_bridge_mappings,
  $ovs_bridge_uplinks           = $quickstack::params::ovs_bridge_uplinks,
  $ovs_l2_population            = 'False',
  $ovs_tunnel_network           = '',
  $ovs_tunnel_types             = $quickstack::params::ovs_tunnel_types,
  $ovs_vlan_ranges              = $quickstack::params::ovs_vlan_ranges,
  $ovs_vxlan_udp_port           = $quickstack::params::ovs_vxlan_udp_port,
  $amqp_provider                = $quickstack::params::amqp_provider,
  $amqp_host                    = $quickstack::params::amqp_host,
  $amqp_port                    = '5672',
  $amqp_ssl_port                = '5671',
  $amqp_username                = $quickstack::params::amqp_username,
  $amqp_password                = $quickstack::params::amqp_password,
  $rabbit_hosts                 = [ ],
  $rabbitmq_use_addrs_not_vip   = true,
  $tenant_network_type          = $quickstack::params::tenant_network_type,
  $tunnel_id_ranges             = '1:1000',
  $verbose                      = $quickstack::params::verbose,
  $ssl                          = $quickstack::params::ssl,
  $mysql_ssl                    = $quickstack::params::mysql_ssl,
  $amqp_ssl                     = $quickstack::params::amqp_ssl,
  $horizon_ssl                  = $quickstack::params::horizon_ssl,

  $security_group_api           = 'neutron',
  $mysql_ca                     = $quickstack::params::mysql_ca,
  $libvirt_images_rbd_pool      = $quickstack::params::libvirt_rbd_pool,
  $libvirt_images_rbd_ceph_conf = $quickstack::params::cinder_rbd_ceph_conf,
  $libvirt_inject_password      = 'false',
  $libvirt_inject_key           = 'false',
  $libvirt_images_type          = 'rbd',
  $rbd_user                     = $quickstack::params::cinder_rbd_user,
  $rbd_secret_uuid              = $quickstack::params::cinder_rbd_secret_uuid,
  $private_ip                   = '',
  $private_network              = '',
  $network_device_mtu           = undef,
  $veth_mtu                     = undef,
  $vnc_keymap                   = 'en-us',
  $vncproxy_host                = undef,
  $vxlan_group                  = '224.0.0.1',
  $use_ssl                      = $quickstack::params::use_ssl_endpoints,
  $cert_file                    = $quickstack::params::neutron_cert,
  $key_file                     = $quickstack::params::neutron_key,
  $ca_file                      = $quickstack::params::root_ca_cert,
  $neutron_pub_url              = $quickstack::params::neutron_pub_url,
  $keystone_admin_url           = $quickstack::params::keystone_admin_url,
  $lenovo_priv_iface            = $quickstack::params::lenovo_priv_iface,
  $quanta_priv_iface            = $quickstack::params::quanta_priv_iface,
  $default_priv_iface           = $quickstack::params::default_priv_iface,
) inherits quickstack::params {

  if $::productname == 'QSSC-S99' {
      $local_ip      = find_ip("$ovs_tunnel_network","$quanta_priv_iface","")
      $private_iface = $quanta_priv_iface
  }
  elsif 'System x3550 M5' in $::productname {
      $local_ip      = find_ip("$ovs_tunnel_network","$lenovo_priv_iface","")
      $private_iface = $lenovo_priv_iface
  }
  else {
      $local_ip      = find_ip("$ovs_tunnel_network","$default_priv_iface","")
      $private_iface = $default_priv_iface
  }

  if str2bool_i("$use_ssl") {
    $auth_protocol = 'https'
  } else {
    $auth_protocol = 'http'
  }

  if str2bool_i("$ssl") {
    if str2bool_i("$amqp_ssl") {
      $qpid_protocol = 'ssl'
      $real_amqp_port = $amqp_ssl_port
    } else {
      $qpid_protocol = 'tcp'
      $real_amqp_port = $amqp_port
    }

    if str2bool_i("$mysql_ssl") {
      $sql_connection = "mysql://${neutron_db_user}:${neutron_db_password}@${mysql_host}/${neutron_db_dbname}?ssl_ca=${mysql_ca}"
    } else {
      $sql_connection = "mysql://${neutron_db_user}:${neutron_db_password}@${mysql_host}/${neutron_db_dbname}"
    }

  } else {
    $qpid_protocol = 'tcp'
    $real_amqp_port = $amqp_port
    $sql_connection = "mysql://${neutron_db_user}:${neutron_db_password}@${mysql_host}/${neutron_db_dbname}"
  }

  # empty array is true in puppet, so deal with that case the long
  # way.  the var $rabbitmq_use_addrs_not_vip provided for consistency
  # with the HA controller.
  if $rabbit_hosts == [ ]  or ! str2bool_i($rabbitmq_use_addrs_not_vip) {
    $_rabbit_hosts = undef
  } else {
    $_rabbit_hosts = split(inline_template('<%= @rabbit_hosts.map {
      |x| x+":"+@amqp_port }.join(",")%>'),",")
  }

  class { '::neutron':
    allow_overlapping_ips => true,
    rpc_backend           => amqp_backend('neutron', $amqp_provider),
    qpid_hostname         => $amqp_host,
    qpid_port             => $real_amqp_port,
    qpid_protocol         => $qpid_protocol,
    qpid_username         => $amqp_username,
    qpid_password         => $amqp_password,
    rabbit_host           => $amqp_host,
    rabbit_port           => $real_amqp_port,
    rabbit_user           => $amqp_username,
    rabbit_password       => $amqp_password,
    rabbit_use_ssl        => $amqp_ssl,
    rabbit_hosts          => $_rabbit_hosts,
    verbose               => $verbose,
    network_device_mtu    => $network_device_mtu,
    use_ssl               => $use_ssl,
    cert_file             => $cert_file,
    key_file              => $key_file,
    ca_file               => $ca_file,
  }
  ->
  class { '::neutron::server::notifications':
    notify_nova_on_port_status_changes => true,
    notify_nova_on_port_data_changes   => true,
    nova_url                           => "${auth_protocol}://${nova_host}:8774/v2",
    nova_admin_auth_url                => "${auth_protocol}://${auth_host}:35357/v2.0",
    nova_admin_username                => "nova",
    nova_admin_password                => "${nova_user_password}",
  }

  neutron_config {
    'database/connection':                  value => $sql_connection;
    'keystone_authtoken/auth_host':         value => $auth_host;
    'keystone_authtoken/admin_tenant_name': value => 'services';
    'keystone_authtoken/admin_user':        value => 'neutron';
    'keystone_authtoken/admin_password':    value => $neutron_user_password;
  }

  if $_rabbit_hosts {
    neutron_config { 'DEFAULT/rabbit_host': ensure => absent }
    neutron_config { 'DEFAULT/rabbit_port': ensure => absent }
  }

  if downcase("$agent_type") == 'ovs' {
    # We don't want all the validation of type_drivers since some of that is
    # inaccurate, just use plugins::ml2 to make sure the package is installed.
    class { '::neutron::plugins::ml2':
      type_drivers => [], #not relevant on compute
    }
    # Just setting the values in plugin file, as the neutron::plugins::ml2 class
    # does extra things right now that are unneeded on compute nodes (like mech
    # drivers, vni_ranges, etc).
    $_ovs_vlan_ranges = join(any2array($ovs_vlan_ranges), ',')
    neutron_plugin_ml2 {
      'ml2_type_vlan/network_vlan_ranges': value => $_ovs_vlan_ranges;
      'ml2_type_vxlan/vxlan_group'       : value => $vxlan_group;
    }

    class { '::neutron::agents::ml2::ovs':
      bridge_uplinks   => $ovs_bridge_uplinks,
      #bridge_mappings  => $ovs_bridge_mappings,
      l2_population    => str2bool_i("$ovs_l2_population"),
      local_ip         => $local_ip,
      enable_tunneling => str2bool_i("$enable_tunneling"),
      tunnel_types     => $ovs_tunnel_types,
      vxlan_udp_port   => $ovs_vxlan_udp_port,
      veth_mtu         => $veth_mtu,
    }

    # We seem to have lost this in the switch away from agents::ovs in
    # puppet-neutron, so adding here.
    # neutron_plugin_ovs { 'agent/veth_mtu': value    => "$veth_mtu"; }
  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_user_password,
    neutron_url            => "${auth_protocol}://${neutron_host}:9696",
    neutron_admin_auth_url => "${auth_protocol}://${auth_host}:35357/v2.0",
    security_group_api     => $security_group_api,
  }


  class { 'quickstack::compute_common':
    auth_host                    => $auth_host,
    ceilometer                   => $ceilometer,
    ceilometer_metering_secret   => $ceilometer_metering_secret,
    ceilometer_user_password     => $ceilometer_user_password,
    manage_ceph_conf             => $manage_ceph_conf,
    ceph_cluster_network         => $ceph_cluster_network,
    ceph_public_network          => $ceph_public_network,
    ceph_fsid                    => $ceph_fsid,
    ceph_images_key              => $ceph_images_key,
    ceph_volumes_key             => $ceph_volumes_key,
    ceph_rgw_key                 => $ceph_rgw_key,
    ceph_mon_host                => $ceph_mon_host,
    ceph_mon_initial_members     => $ceph_mon_initial_members,
    ceph_conf_include_osd_global => $ceph_conf_include_osd_global,
    ceph_osd_pool_size           => $ceph_osd_pool_size,
    ceph_osd_journal_size        => $ceph_osd_journal_size,
    ceph_osd_mkfs_options_xfs    => $ceph_osd_mkfs_options_xfs,
    ceph_osd_mount_options_xfs   => $ceph_osd_mount_options_xfs,
    ceph_conf_include_rgw        => $ceph_conf_include_rgw,
    ceph_rgw_hostnames           => $ceph_rgw_hostnames,
    ceph_extra_conf_lines        => $ceph_extra_conf_lines,
    cinder_backend_gluster       => $cinder_backend_gluster,
    cinder_backend_nfs           => $cinder_backend_nfs,
    cinder_backend_rbd           => $cinder_backend_rbd,
    cinder_catalog_info          => $cinder_catalog_info,
    glance_backend_rbd           => $glance_backend_rbd,
    glance_host                  => $glance_host,
    mysql_host                   => $mysql_host,
    nova_db_password             => $nova_db_password,
    nova_host                    => $nova_host,
    vncproxy_host                => pick($vncproxy_host, $nova_host),
    nova_user_password           => $nova_user_password,
    amqp_provider                => $amqp_provider,
    amqp_host                    => $amqp_host,
    amqp_port                    => $amqp_port,
    amqp_ssl_port                => $amqp_ssl_port,
    amqp_username                => $amqp_username,
    amqp_password                => $amqp_password,
    rabbit_hosts                 => $_rabbit_hosts,
    verbose                      => $verbose,
    ssl                          => $ssl,
    mysql_ca                     => $mysql_ca,
    libvirt_images_rbd_pool      => $libvirt_images_rbd_pool,
    libvirt_images_rbd_ceph_conf => $libvirt_images_rbd_ceph_conf,
    libvirt_inject_password      => $libvirt_inject_password,
    libvirt_inject_key           => $libvirt_inject_key,
    libvirt_images_type          => $libvirt_images_type,
    rbd_user                     => $rbd_user,
    rbd_secret_uuid              => $rbd_secret_uuid,
    private_iface                => $private_iface,
    private_ip                   => $private_ip,
    private_network              => $private_network,
    network_device_mtu           => $network_device_mtu,
    vnc_keymap                   => $vnc_keymap,
    mysql_ssl                    => $mysql_ssl,
    amqp_ssl                     => $amqp_ssl,
    horizon_ssl                  => $horizon_ssl,
  }

#  class {'quickstack::neutron::firewall::gre':}

#  class {'quickstack::neutron::firewall::vxlan':
#    port => $ovs_vxlan_udp_port,
#  }

  class {'moc_config::server_config':}

  # Security Rules fix for Openstack Instances
  sysctl::value { 'net.ipv4.conf.all.rp_filter': value => 0 }
  sysctl::value { 'net.ipv4.conf.default.rp_filter': value => 0 }
  sysctl::value { 'net.bridge.bridge-nf-call-iptables': value => 1 }
  sysctl::value { 'net.bridge.bridge-nf-call-ip6tables': value => 1 }
}
