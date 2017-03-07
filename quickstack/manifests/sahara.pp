class quickstack::sahara (
  $sahara_password       = $quickstack::params::sahara_password,
  $sahara_db_password    = $quickstack::params::sahara_db_password,
  $sahara_debug          = $quickstack::params::sahara_debug,
  $heat_domain_password  = $quickstack::params::heat_domain_password,
  $sahara_plugins        = $quickstack::params::sahara_plugins,
  $keystone_auth_uri     = "${quickstack::params::auth_uri}v2.0/",
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
    use_floating_ips    => false,
  }

  sahara_config {
    'DEFAULT/heat_enable_wait_condition': value => false;
    'DEFAULT/plugins':                    value => $sahara_plugins;
    'DEFAULT/use_namespaces':             value => false;
    'DEFAULT/proxy_command':              value => "\'ip netns exec qdhcp-{network_id} nc {host} {port}\'";
    'DEFAULT/use_rootwrap':               value => true;
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
      notify => Service['openstack-sahara-all'], # only restarts if change
      ensure => file,
      owner  => 'root',
      group  => 'sahara',
      mode   => '0640',
      source => 'puppet:///modules/quickstack/sahara_policy.json',
    }
  }
  
  file_line { 'spark_cleanup':
    notify  => Service['openstack-sahara-all'], # only restarts Sahara if a file changes
    path    => '/usr/lib/python2.7/site-packages/sahara/plugins/spark/plugin.py',
    line    => '        return ["1.6.0"]',
    after   => "    def get_versions\u0028self\u0029:"
  }

  file_line { 'storm_cleanup':
    notify  => Service['openstack-sahara-all'], # only restarts Sahara if a file changes
    path    => '/usr/lib/python2.7/site-packages/sahara/plugins/storm/plugin.py',
    line    => '        return ["1.0.1", "0.9.2"]',
    after   => "    def get_versions\u0028self\u0029:"
  }

  if str2bool(hiera('swift_endpoint::real', 'false')) {
    $swift = "'object-store'"
  } else {
    $swift = ""
  }

  file_line { 'swift_dns':
    # this fix is no longer necessary on Newton, but keeping it won't break anything
    notify => Service['openstack-sahara-all'], # only restarts if change
    path   => '/usr/lib/python2.7/site-packages/sahara/utils/cluster.py',
    line   => "    for service in [${swift}]:",
    match  => "(    for service in).*"
  }

  $controller_ip_addr = hiera('ha::vip')

  file_line { 'identity_dns':
    notify => Service['openstack-sahara-all'], # only restarts if change
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

  file_line { 'pig_note': # Might fail on first Puppet run
    notify => Service['httpd'], # only restarts if change
    path   => '/usr/lib/python2.7/site-packages/sahara_dashboard/content/data_processing/jobs/templates/job_templates/_create_job_help.html',
    line   => '    <li>{% blocktrans %}Pig - <a href="https://github.com/jeremyfreudberg/sahara-image-elements/wiki/Running-Pig-jobs-on-Vanilla-MOC-Remix-clusters">See Note</a>{% endblocktrans %}</li>',
    match  => '.*(Pig).*'
  }

}
