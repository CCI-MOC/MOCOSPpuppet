class quickstack::sahara (
  $sahara_password       = $quickstack::params::sahara_password,
  $sahara_db_password    = $quickstack::params::sahara_db_password,
  $sahara_debug          = $quickstack::params::sahara_debug,
  $heat_domain_password  = $quickstack::params::heat_domain_password,
  $sahara_plugins        = $quickstack::params::sahara_plugins,
  $keystone_auth_uri     = "${quickstack::params::auth_uri}/v2.0/",
  $keystone_identity_uri = $quickstack::params::identity_uri,
  $keystone_tenant_name  = 'services',
  $keystone_region_name  = $openstack::keystone::region,
  $rabbit_userid         = $quickstack::params::amqp_username,
  $rabbit_password       = $quickstack::params::amqp_password,
  $hostname              = $quickstack::params::controller_admin_host,
  $sahara_use_ssl        = $quickstack::params::use_ssl_endpoints,
  $sahara_key            = $quickstack::params::sahara_key,
  $sahara_cert           = $quickstack::params::sahara_cert,
  $sahara_manage_policy  = $quickstack::params::sahara_manage_policy,
) {

  exec { 'sahara_service_cleanup':
    command => "systemctl stop openstack-sahara-all; systemctl disable openstack-sahara-all; systemctl stop openstack-sahara-api; systemctl disable openstack-sahara-api",
    path => '/bin'
  }
 
  if str2bool_i($sahara_use_ssl) {
      class {'moc_openstack::ssl::add_sahara_cert':
      }
    }

  class { '::sahara':
    debug               => $sahara_debug,
    log_dir             => '/var/log/sahara',
    use_neutron         => true,
    keystone_username   => 'sahara',
    keystone_password   => $sahara_password,
    keystone_tenant     => $keystone_tenant_name,
    keystone_url        => $keystone_auth_uri,
    identity_url        => $keystone_identity_uri,
    service_host        => '0.0.0.0',
    service_port        => 8386,
    use_floating_ips    => true,
  }

  file { '/etc/httpd/conf.d/sahara-api.conf':
    notify  => Service['httpd'],
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['httpd'],
    source => 'puppet:///modules/quickstack/sahara-api.conf'
  }


  sahara_config {
    'DEFAULT/heat_enable_wait_condition': value => false;
    'DEFAULT/plugins':                    value => $sahara_plugins;
    'DEFAULT/use_namespaces':             value => false;
    'DEFAULT/proxy_command':              value => "\'ip netns exec qdhcp-{network_id} nc {host} {port}\'";
    'DEFAULT/use_rootwrap':               value => true;
    'DEFAULT/proxy_command_use_internal_ip': value => true;
    'cinder/api_version': value => 2;
  }
  
  if str2bool_i($sahara_use_ssl) { 
    sahara_config {
      'ssl/key_file': value => $sahara_key;
      'ssl/cert_file': value => $sahara_cert;
    }
  }

  if str2bool_i($sahara_use_ssl) {
    $endpoint_url = "https://${hostname}:8386/v1.1/%(tenant_id)s"
  } else {
    $endpoint_url = "http://${hostname}:8386/v1.1/%(tenant_id)s"
  }

  class { '::sahara::keystone::auth':
    password     => $sahara_password,
    auth_name    => 'sahara',
    tenant       => $keystone_tenant_name,
    region       => $keystone_region_name,
    public_url   => $endpoint_url, 
    admin_url    => $endpoint_url, 
    internal_url => $endpoint_url,
  }

  class { '::sahara::notify::rabbitmq':
    rabbit_userid   => $rabbit_userid,
    rabbit_password => $rabbit_password,
  }

  if str2bool_i($sahara_manage_policy) {
    keystone_role { ['sahara_admin']:
      ensure => present,
    }
    file { '/etc/sahara/policy.json':
      notify => Service['httpd', 'openstack-sahara-engine'], # only restarts if change
      ensure => file,
      owner  => 'root',
      group  => 'sahara',
      mode   => '0640',
      source => 'puppet:///modules/quickstack/sahara_policy.json',
    }
  }
  
  file_line { 'swift_dns':
    notify => Service['httpd', 'openstack-sahara-engine'], # only restarts if change
    path   => '/usr/lib/python2.7/site-packages/sahara/utils/cluster.py',
    line   => "    for service in []:",
    match  => "(    for service in).*"
  }

  $controller_ip_addr = hiera('ha::vip')

  file_line { 'identity_dns':
    notify => Service['httpd', 'openstack-sahara-engine'], # only restarts if change
    path   => '/usr/lib/python2.7/site-packages/sahara/utils/cluster.py',
    line   => "    hosts = \"127.0.0.1 localhost\\n${controller_ip_addr} ${hostname}\\n\"",
    match  => '.*(localhost).*'
  }

  file { '/etc/sudoers.d/sahara-rootwrap':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => 'puppet:///modules/quickstack/sahara-rootwrap.fix'
  }

}
