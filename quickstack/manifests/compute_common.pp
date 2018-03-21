# == Class: quickstack::compute_common
#
# A base class to configure compute nodes
#
# === Parameters
# [*nova_host*]
#   The private network ip for the controller, or nova VIP, if HA.
# [*vncproxy_host*]
#   The ip or hostname to use for constructing the VNC console base URL.
#   Typically the public network ip or hostname for the controller, or nova VIP, if HA.
#   Defaults to the value of nova_host if unset.

class quickstack::compute_common (
  $sahara_enabled               = $quickstack::params::sahara_enabled,
  $amqp_host                    = $quickstack::params::amqp_host,
  $amqp_password                = $quickstack::params::amqp_password,
  $amqp_port                    = '5672',
  $amqp_provider                = $quickstack::params::amqp_provider,
  $amqp_username                = $quickstack::params::amqp_username,
  $amqp_ssl_port                = '5671',
  $auth_host                    = $quickstack::params::controller_pub_host,
  $ceilometer                   = 'false',
  $ceilometer_metering_secret   = $quickstack::params::ceilometer_metering_secret,
  $ceilometer_user_password     = $quickstack::params::ceilometer_user_password,
  $manage_ceph_conf             = false,
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
  $cinder_backend_rbd           = 'false',
  $cinder_catalog_info          = 'volume:cinder:internalURL',
  $glance_host                  = $quickstack::params::controller_pub_host,
  $glance_backend_rbd           = 'true',
  $libvirt_images_rbd_pool      = $quickstack::params::libvirt_rbd_pool,
  $libvirt_images_rbd_ceph_conf = '/etc/ceph/ceph.conf',
  $libvirt_inject_password      = 'false',
  $libvirt_inject_key           = 'false',
  $libvirt_images_type          = 'rbd',
  $mysql_ca                     = $quickstack::params::mysql_ca,
  $mysql_host                   = $quickstack::params::mysql_host,
  $nova_host                    = $quickstack::params::controller_pub_host,
  $nova_db_password             = $quickstack::params::nova_db_password,
  $nova_user_password           = $quickstack::params::nova_user_password,
  $private_network              = '',
  $private_iface                = '',
  $private_ip                   = '',
  $rabbit_hosts                 = undef,
  $rbd_user                     = $quickstack::params::cinder_rbd_user,
  $rbd_secret_uuid              = $quickstack::params::cinder_rbd_secret_uuid,
  $network_device_mtu           = $quickstack::params::network_device_mtu,
  $ssl                          = $quickstack::params::ssl,
  $mysql_ssl                    = $quickstack::params::mysql_ssl,
  $amqp_ssl                     = $quickstack::params::amqp_ssl,
  $horizon_ssl                  = $quickstack::params::horizon_ssl,
  $verbose                      = $quickstack::params::verbose,
  $keystonerc                   = true, 
  $vnc_keymap                   = 'en-us',
  $vncproxy_host                = undef,
  $glance_priv_url              = $quickstack::params::glance_priv_url,
  $use_ssl                      = $quickstack::params::use_ssl_endpoints,
  $enabled_ssl_apis             = ['osapi_compute'],
  $key_file                     = $quickstack::params::nova_key,
  $cert_file                    = $quickstack::params::nova_cert,
  $ca_file                      = $quickstack::params::root_ca_cert,
  $auth_uri                     = $quickstack::params::keystone_pub_url,
  $identity_uri                 = $quickstack::params::keystone_admin_url,
  $neutron                      = $quickstack::params::neutron,
  $ceph_nodes                   = $quickstack::params::ceph_nodes,
  $ceph_enpoints                = $quickstack::params::ceph_endpoints,
  $ceph_user                    = $quickstack::params::ceph_user,
  $nova_uuid                    = $quickstack::params::nova_uuid,
  $rbd_key                      = $quickstack::params::rbd_key,
  $ceph_vlan                    = $quickstack::params::ceph_vlan,
  $sensu_client_enable          = $quickstack::params::sensu_client_enable,
  $sensu_rabbitmq_host          = $quickstack::params::sensu_rabbitmq_host,
  $sensu_rabbitmq_user          = $quickstack::params::sensu_rabbitmq_user,
  $sensu_rabbitmq_password      = $quickstack::params::sensu_rabbitmq_password,
  $sensu_client_subscriptions   = $quickstack::params::sensu_subscriptions_compute,
  $sensu_client_keepalive       = { 
                                    "thresholds" => { 
                                      "warning"  => 60, 
                                      "critical" => 300 
                                    }, 
                                    "handlers"   => $quickstack::params::sensu_handlers_compute, 
                                    "refresh" => 3600 
                                  },
  $public_net                   = $quickstack::params::public_net,
  $private_net                  = $quickstack::params::private_net,
  $ntp_local_servers            = $quickstack::params::ntp_local_servers,
  $elasticsearch_host           = $quickstack::params::elasticsearch_host,
  $backups_enabled 		= $quickstack::params::backups_enabled,
  $backups_user                 = $quickstack::params::backups_user,
  $backups_script_src           = $quickstack::params::backups_script_compute,
  $backups_script_local         = $quickstack::params::backups_script_local_name,
  $backups_dir                  = $quickstack::params::backups_directory,
  $backups_log                  = $quickstack::params::backups_log,
  $backups_verbose              = $quickstack::params::backups_verbose,
  $backups_email                = $quickstack::params::backups_email,
  $backups_ssh_key              = $quickstack::params::backups_ssh_key,
  $backups_sudoers_d            = $quickstack::params::backups_sudoers_d,
  $backups_hour                 = $quickstack::params::backups_local_hour,
  $backups_min                  = $quickstack::params::backups_local_min, 
  $backups_keep_days		= $quickstack::params::backups_keep_days,
  $allow_resize_to_same_host    = $quickstack::params::allow_resize,
  $allow_migrate_to_same_host   = $quickstack::params::allow_migrate,
  $repo_server                  = $quickstack::params::repo_server,
  $r730xd_pub_iface             = $quickstack::params::r730xd_pub_iface,
  $r730xd_priv_iface            = $quickstack::params::r730xd_priv_iface,
  $r730xd_ceph_iface            = $quickstack::params::r730xd_ceph_iface,
  $lenovo_pub_iface             = $quickstack::params::lenovo_pub_iface,
  $lenovo_priv_iface            = $quickstack::params::lenovo_priv_iface,
  $lenovo_ceph_iface            = $quickstack::params::lenovo_ceph_iface,
  $quanta_pub_iface             = $quickstack::params::quanta_pub_iface,
  $quanta_priv_iface            = $quickstack::params::quanta_priv_iface,
  $quanta_ceph_iface            = $quickstack::params::quanta_ceph_iface,
  $default_pub_iface            = $quickstack::params::default_pub_iface,
  $default_priv_iface           = $quickstack::params::default_priv_iface,
  $default_ceph_iface           = $quickstack::params::default_ceph_iface,
  $priv_netmask                 = $quickstack::params::priv_netmask,
  $priv_net                     = $quickstack::params::priv_net,
  $ceph_net                     = $quickstack::params::ceph_net,
  $ceph_netmask                 = $quickstack::params::ceph_netmask,
  $admin_password               = $quickstack::params::admin_password,
  $enable_ceilometer            = $quickstack::params::enable_ceilometer,
  $controller_admin_host        = $quickstack::params::controller_admin_host,
  $ceilometer_backend           = $quickstack::params::ceilometer_backend
) inherits quickstack::params {

  if str2bool_i("$use_ssl") {
    $auth_protocol = 'https'
  } else {
    $auth_protocol = 'http'
  }

  # Create entries in /etc/hosts
  class {'hosts':}
  if $::productname == 'QSSC-S99' {
    $pub_iface  = $quanta_pub_iface
    $priv_iface = $quanta_priv_iface
    $ceph_iface = $quanta_ceph_iface
  }
  elsif 'System x3550 M5' in $::productname {
    $pub_iface  = $lenovo_pub_iface
    $priv_iface = $lenovo_priv_iface
    $ceph_iface = $lenovo_ceph_iface
  }
  elsif 'PowerEdge R730' in $::productname {
    $pub_iface  = $r730xd_pub_iface
    $priv_iface = $r730xd_priv_iface
    $ceph_iface = $r730xd_ceph_iface
  }
  else {
    $pub_iface  = $default_pub_iface
    $priv_iface = $default_priv_iface
    $ceph_iface = $default_ceph_iface
  }

  class {'quickstack::openstack_common': }

  # Temporary fix for glanceclient bug: 1244291
#  class {'moc_openstack::ssl::temp_glance_fix':
#    require => Package['nova-common'],
#  }

  if str2bool_i("$use_ssl") {
    if str2bool_i("$amqp_ssl") {
      $qpid_protocol = 'ssl'
      $real_amqp_port = $amqp_ssl_port
    } else {
      $qpid_protocol = 'tcp'
      $real_amqp_port = $amqp_port
    }

    if str2bool_i("$mysql_ssl") {
      $nova_sql_connection = "mysql://nova:${nova_db_password}@${mysql_host}/nova?ssl_ca=${mysql_ca}"
    } else {
      $nova_sql_connection = "mysql://nova:${nova_db_password}@${mysql_host}/nova"
    }

    class {'moc_openstack::ssl::install_rootca':
      before => Package['nova-common'],
    }
  } else {
    $qpid_protocol = 'tcp'
    $real_amqp_port = $amqp_port
    $nova_sql_connection = "mysql://nova:${nova_db_password}@${mysql_host}/nova"
  }

  if str2bool_i($kvm_capable) {
    $libvirt_type = 'kvm'
  } else {
    include quickstack::compute::qemu
    $libvirt_type = 'qemu'
  }

  if str2bool_i("$cinder_backend_gluster") {
    if defined('gluster::client') {
      class { 'gluster::client': }
    } else {
      include ::puppet::vardir
      class { 'gluster::mount::base': repo => false }
    }


    if ($::selinux != "false") {
      selboolean{'virt_use_fusefs':
          value => on,
          persistent => true,
      }
    }

    nova_config {
      'DEFAULT/qemu_allowed_storage_drivers': value => 'gluster';
    }
  }
  if str2bool_i("$cinder_backend_nfs") {
    package { 'nfs-utils':
      ensure => 'present',
    }

    if ($::selinux != "false") {
      selboolean{'virt_use_nfs':
          value => on,
          persistent => true,
      }
    }
  }

  if (str2bool_i("$cinder_backend_rbd") or str2bool_i("$glance_backend_rbd")) {
    include ::quickstack::ceph::client_packages
    if $ceph_fsid {
      class { '::quickstack::ceph::config':
        manage_ceph_conf        => $manage_ceph_conf,
        fsid                    => $ceph_fsid,
        cluster_network         => $ceph_cluster_network,
        public_network          => $ceph_public_network,
        mon_initial_members     => $ceph_mon_initial_members,
        mon_host                => $ceph_mon_host,
        images_key              => $ceph_images_key,
        volumes_key             => $ceph_volumes_key,
        rgw_key                 => $ceph_rgw_key,
        conf_include_osd_global => $ceph_conf_include_osd_global,
        osd_pool_default_size   => $ceph_osd_pool_size,
        osd_journal_size        => $ceph_osd_journal_size,
        osd_mkfs_options_xfs    => $ceph_osd_mkfs_options_xfs,
        osd_mount_options_xfs   => $ceph_osd_mount_options_xfs,
        conf_include_rgw        => $ceph_conf_include_rgw,
        rgw_hostnames           => $ceph_rgw_hostnames,
        extra_conf_lines        => $ceph_extra_conf_lines,
      } -> Class['quickstack::ceph::client_packages']
    }
    package {'python-rbd': } ->
    Class['quickstack::ceph::client_packages'] -> Package['nova-compute']
  }

  if str2bool_i("$cinder_backend_rbd") {
    nova_config {
      'libvirt/images_rbd_pool':      value => $libvirt_images_rbd_pool;
      'libvirt/images_rbd_ceph_conf': value => $libvirt_images_rbd_ceph_conf;
      'libvirt/images_type':          value => $libvirt_images_type;
      'libvirt/rbd_user':             value => $rbd_user;
      'libvirt/rbd_secret_uuid':      value => $rbd_secret_uuid;
      'libvirt/live_migration_flag':  value => '"VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST"';
    }
    class { '::nova::compute::libvirt':
      libvirt_virt_type        => $libvirt_type,
      vncserver_listen         => '0.0.0.0',
      libvirt_inject_key       => $libvirt_inject_key,
      libvirt_inject_partition => -2,
      libvirt_inject_password  => $libvirt_inject_password,
      libvirt_disk_cachemodes  => ['"network=writeback"'],
      migration_support        => true,
    }

    Package['nova-common'] ->
    # This defines the cinder secret for libvirt
    class { 'moc_openstack::configure_nova_ceph':
           nova_uuid     => $nova_uuid,
           ceph_key      => $ceph_key,
           ceph_user     => $ceph_user,
    }
  } else {
    class { '::nova::compute::libvirt':
      libvirt_virt_type        => $libvirt_type,
      vncserver_listen         => '0.0.0.0',
      libvirt_inject_partition => -1,
    }
  }

  nova_config {
    'DEFAULT/cinder_catalog_info':        value => $cinder_catalog_info;
    'DEFAULT/allow_resize_to_same_host':  value => $allow_resize_to_same_host;
    'DEFAULT/allow_migrate_to_same_host': value => $allow_migrate_to_same_host;
  }

  if $rabbit_hosts {
    nova_config { 'DEFAULT/rabbit_host': ensure => absent }
    nova_config { 'DEFAULT/rabbit_port': ensure => absent }
  }

  class { '::nova':
    #database_connection => $nova_sql_connection,
    image_service       => 'nova.image.glance.GlanceImageService',
    glance_api_servers  => "${glance_priv_url}/v1",
    rpc_backend         => amqp_backend('nova', $amqp_provider),
    qpid_hostname       => $amqp_host,
    qpid_protocol       => $qpid_protocol,
    qpid_port           => $real_amqp_port,
    qpid_username       => $amqp_username,
    qpid_password       => $amqp_password,
    rabbit_host         => $amqp_host,
    rabbit_port         => $real_amqp_port,
    rabbit_userid       => $amqp_username,
    rabbit_password     => $amqp_password,
    rabbit_use_ssl      => $amqp_ssl,
    rabbit_hosts        => $rabbit_hosts,
    verbose             => $verbose,
    controller_pub_host => $controller_pub_host,
    use_ssl             => $use_ssl,
    enabled_ssl_apis    => ['osapi_compute'],
    key_file            => $key_file,
    cert_file           => $cert_file,
    ca_file             => $ca_file,
  }

  $compute_ip = find_ip("$private_network",
                        "$private_iface",
                        "$private_ip")
  class { '::nova::compute':
    enabled                       => true,
    vncproxy_host                 => pick($vncproxy_host, $nova_host),
    vncserver_proxyclient_address => $compute_ip,
    network_device_mtu            => $network_device_mtu,
    vnc_keymap                    => $vnc_keymap,
    auth_protocol                 => $auth_protocol,
    auth_uri                      => $auth_uri,
    identity_uri                  => $identity_uri,
  }

  if str2bool_i("$neutron") {
    class { '::nova::api':
      enabled           => false,
      admin_password    => $nova_user_password,
      auth_host         => $controller_priv_host,
      auth_protocol     => $auth_protocol,
      auth_uri          => $keystone_pub_url,
      identity_uri      => $keystone_admin_url,
      neutron_metadata_proxy_shared_secret => $neutron_metadata_proxy_secret,
    }
  } else {
    class { '::nova::api':
      enabled           => false,
      admin_password    => $nova_user_password,
      auth_host         => $controller_priv_host,
      auth_protocol     => $auth_protocol,
      auth_uri          => $keystone_pub_url,
      identity_uri      => $keystone_admin_url,
    }
  }
  if str2bool_i("$enable_ceilometer") {
    if str2bool_i("$ceilometer") {
      class { 'ceilometer':
        telemetry_secret => $ceilometer_metering_secret,
        qpid_protocol    => $qpid_protocol,
        qpid_username    => $amqp_username,
        qpid_password    => $amqp_password,
        rabbit_host      => $amqp_host,
        rabbit_hosts     => $rabbit_hosts,
        rabbit_port      => $real_amqp_port,
        rabbit_userid    => $amqp_username,
        rabbit_password  => $amqp_password,
        rabbit_use_ssl   => $amqp_ssl,
        rpc_backend      => $ceilometer_backend,
        verbose          => $verbose,
      }
      class { 'ceilometer::agent::compute':
        enabled => true,
      }
      Package['openstack-nova-common'] -> Package['ceilometer-common']
    }
    class { 'ceilometer::client::compute': }
    include quickstack::tuned::virtual_host
  }


#  firewall { '000 block vnc access for all except controller':
#    proto  => 'tcp',
#    dport  => '5900-5999',
#    source => "!$controller_private_ip",
#    action => 'drop',
#  }

#Customization for intalling ceph and conf files  
  class { 'moc_openstack::install_ceph':
    ceph_nodes     => $ceph_nodes,
    ceph_endpoints => $ceph_endpoints,
    ceph_user      => $ceph_user,
    ceph_vlan      => $ceph_vlan,
    ceph_key       => $ceph_key,
    ceph_iface     => $ceph_iface,
    ceph_net       => $ceph_net,
    ceph_netmask   => $ceph_netmask,
  }

  class { 'moc_openstack::firewall':
    interface   => $ceph_iface,
    public_net  => $public_net,
    private_net => $private_net,
  }

# Ensure ruby has lastest version
  package { "ruby":
    ensure => latest,
  }

  package { "rubygems":
    ensure => latest,
  }
#Other packages needed
  package { "yum-utils":
    ensure => latest,
  }

  package { "openstack-utils":
    ensure => latest,
  }

  package { "openstack-nova-placement-api":
    ensure => latest,
  }

#  if $operatingsystem== 'CentOS' {
#      package {"centos-release-openstack-ocata":
#        ensure => latest,
#      }
#  }



#This belongs in a separate manifest and needs to be declared here not defined
#Customization for configuring sensu
if hiera('moc::usesensu') == 'true' {
    class { '::sensu':
      client                => $sensu_client_enable,
      sensu_plugin_name     => 'sensu-plugin',
      sensu_plugin_version  => 'installed',
      sensu_plugin_provider => 'gem',
      purge_config          => true,
      rabbitmq_host         => $sensu_rabbitmq_host,
      rabbitmq_user         => $sensu_rabbitmq_user,
      rabbitmq_password     => $sensu_rabbitmq_password,
      rabbitmq_vhost        => '/sensu',
      subscriptions         => $sensu_client_subscriptions,
      client_keepalive      => $sensu_client_keepalive,
      plugins               => [
         "puppet:///modules/sensu/plugins/check-mem.sh",
         "puppet:///modules/sensu/plugins/cpu-metrics.rb",
         "puppet:///modules/sensu/plugins/disk-usage-metrics.rb",
         "puppet:///modules/sensu/plugins/load-metrics.rb",
         "puppet:///modules/sensu/plugins/check-ceph.rb",
         "puppet:///modules/sensu/plugins/check-disk-fail.rb",
         "puppet:///modules/sensu/plugins/memory-metrics.rb",
         "puppet:///modules/sensu/plugins/uptime-metrics.py",
         "puppet:///modules/sensu/plugins/check_keystone-api.sh",
         "puppet:///modules/sensu/plugins/keystone-token-metrics.rb",
         "puppet:///modules/sensu/plugins/nova-hypervisor-metrics.py",
         "puppet:///modules/sensu/plugins/nova-server-state-metrics.py",
         "puppet:///modules/sensu/plugins/cpu-pcnt-usage-metrics.rb",
         "puppet:///modules/sensu/plugins/disk-metrics.rb",
         "puppet:///modules/sensu/plugins/vmstat-metrics.rb",
         "puppet:///modules/sensu/plugins/iostat-metrics.rb",
         "puppet:///modules/sensu/plugins/vm-metrics.py"
      ]
    }

   file { '/etc/sudoers.d/sensu-rootwrap':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => 'puppet:///modules/quickstack/sensu-rootwrap.fix'
  }
}

  class {'quickstack::ntp':
    servers => $ntp_local_servers,
  }

#  class { 'filebeat':
#    outputs => {
#      'logstash' => {
#        'hosts'       => [$elasticsearch_host],
#        'loadbalance' => true
#      }
#    },
#    logging => {
#      'level'    => "info"
#    }
#  }
#
#  filebeat::prospector {'syslog':
#    paths    => [
#      '/var/log/*.log',
#      '/var/log/secure',
#      '/var/log/messages',
#    ],
#    doc_type => 'syslog',
#  }
#
#  filebeat::prospector {'neutron':
#    paths    => [
#      '/var/log/neutron/*.log',
#    ],
#    doc_type => 'neutron',
#  }
#
#  filebeat::prospector {'nova':
#    paths    => [
#      '/var/log/nova/*.log',
#    ],
#    doc_type => 'nova',
#  }
#
#  filebeat::prospector {'ceilometer':
#    paths    => [
#      '/var/log/ceilometer/*.log',
#    ],
#    doc_type => 'ceilometer',
#  }

  # Installs scripts for automated backups  
  package { "rsync":
      ensure => latest,
  }
if hiera('moc::dobackups') == 'true' {
  class {'backups':
    enabled      => $backups_enabled,
    user         => $backups_user,
    script_src   => $backups_script_src,
    script_local => $backups_script_local,
    backups_dir  => $backups_dir,
    log_file     => $backups_log,
    verbose      => $backups_verbose,
    ssh_key      => $backups_ssh_key,
    sudoers_d    => $backups_sudoers_d,
    cron_email   => $backups_email,
    cron_hour    => $backups_hour,
    cron_min     => $backups_min, 
    keep_days    => $backups_keep_days,
  }
}

  class {'moc_openstack::cronjob':
    repo_server => $repo_server,
    randomwait => 240,
  }

  class {'moc_openstack::suricata':
  }
  class {'moc_openstack::configure_privnet':
    priv_iface   => $priv_iface,
    priv_netmask => $priv_netmask,
    priv_net     => $priv_net,
    before => Class['hosts'],
  }
  if str2bool_i("$keystonerc") {
    class { 'quickstack::admin_client':
      admin_password        => $admin_password,
      controller_admin_host => $controller_admin_host,
      auth_protocol         => $auth_protocol,
    }
  }

  class {'moc_openstack::nova_resize':
    require => Package['nova-common'],
  }

package { 'qemu-kvm-common':
  ensure => present,
  } ->
   service { 'ksm':
     ensure => running,
     enable => true,
   } ->
   service { 'ksmtuned':
     ensure => running,
     enable => true,
   }

  include sysstat
}
