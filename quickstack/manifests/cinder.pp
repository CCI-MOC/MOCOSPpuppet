class quickstack::cinder(
  $user_password  = 'cinder',
  $bind_host      = '0.0.0.0',
  $db_host        = '127.0.0.1',
  $db_name        = 'cinder',
  $db_user        = 'cinder',
  $db_password    = '',
  $max_retries    = '',
  $db_ssl         = false,
  $db_ssl_ca      = '',
  $glance_host    = '127.0.0.1',
  $keystone_host  = '127.0.0.1',
  $use_syslog     = false,
  $log_facility   = 'LOG_USER',

  $rpc_backend    = 'cinder.openstack.common.rpc.impl_kombu',
  $amqp_host      = '127.0.0.1',
  $amqp_port      = '5672',
  $amqp_username  = '',
  $amqp_password  = '',
  $qpid_heartbeat = '60',
  $qpid_protocol  = 'tcp',
  $rabbit_use_ssl = false,
  $rabbit_hosts   = undef,

  $enabled        = true,
  $manage_service = true,
  $debug          = false,
  $verbose        = false,
  $auth_uri       = 'http://localhost:5000/v2.0',
  $identity_uri   = 'http://localhost:35357/v2.0',
  $cert_file      = '/etc/pki/tls/certs/cinder.crt',
  $key_file       = '/etc/pki/tls/private/cinder.key',
  $ca_file        = '/etc/pki/ca-trust/source/anchors/rootCA.crt',
  $use_ssl        = false,
  $nova_pub_url   = 'http://localhost:8774/',
) {
#  include ::quickstack::firewall::cinder

  if str2bool_i("$use_ssl") {
    $auth_protocol = 'https'
  } else {
    $auth_protocol = 'http'
  }

  $amqp_password_safe_for_cinder = $amqp_password ? {
    ''      => 'guest',
    false   => 'guest',
    default => $amqp_password,
  }

  cinder_config {
    'DEFAULT/glance_host': value => $glance_host;
    'DEFAULT/osapi_volume_use_ssl': value => True ;
    'DEFAULT/notification_driver': value => 'cinder.openstack.common.notifier.rpc_notifier'
  }
  if $max_retries {
    cinder_config {
      'DEFAULT/max_retries':      value => $max_retries;
    }
  }

  if str2bool_i("$db_ssl") {
    $sql_connection = "mysql://${db_user}:${db_password}@${db_host}/${db_name}?ssl_ca=${db_ssl_ca}"
  } else {
    $sql_connection = "mysql://${db_user}:${db_password}@${db_host}/${db_name}"
  }

  class {'::cinder':
    rpc_backend         => $rpc_backend,
    qpid_hostname       => $amqp_host,
    qpid_port           => $amqp_port,
    qpid_username       => $amqp_username,
    qpid_password       => $amqp_password_safe_for_cinder,
    qpid_heartbeat      => $qpid_heartbeat,
    qpid_protocol       => $qpid_protocol,
    rabbit_host         => $amqp_host,
    rabbit_port         => $amqp_port,
    rabbit_userid       => $amqp_username,
    rabbit_password     => $amqp_password_safe_for_cinder,
    rabbit_use_ssl      => $rabbit_use_ssl,
    rabbit_hosts        => $rabbit_hosts,
    database_connection => $sql_connection,
    verbose             => str2bool_i("$verbose"),
    use_syslog          => str2bool_i("$use_syslog"),
    log_facility        => $log_facility,
    use_ssl             => $use_ssl,
    cert_file           => $cert_file,
    key_file            => $key_file,
    ca_file             => $ca_file,
    auth_uri            => $auth_uri,
    identity_uri        => $identity_uri,
    enable_v1_api       => false,
  }
  # FIXME: after we drop support for Puppet <= 3.6, we can use
  # `contain ::cinder` instead of the anchors here, and use fully qualified
  # class names in the rest of `contain` statements too
  anchor { 'quickstack-cinder-first': } ->
  Class['::cinder'] ->
  anchor { 'quickstack-cinder-last': }

  class {'::cinder::api':
    keystone_password      => $user_password,
    keystone_tenant        => "services",
    keystone_user          => "cinder",
    enabled                => str2bool_i("$enabled"),
    manage_service         => str2bool_i("$manage_service"),
    bind_host              => $bind_host,
    auth_uri               => $auth_uri,
    identity_uri           => $identity_uri,
  }

  class {'::cinder::scheduler':
    enabled        => str2bool_i("$enabled"),
    manage_service => str2bool_i("$manage_service"),
  }
}
