class quickstack::heat_controller(
  $sahara_enabled = $quickstack::params::sahara_enabled,
  $auth_encryption_key,
  $heat_cfn,
  $heat_cloudwatch,
  $heat_user_password,
  $heat_db_password,
  $controller_admin_host,
  $controller_priv_host,
  $controller_pub_host,
  $mysql_ca,
  $mysql_host,
  $ssl,
  $amqp_provider,
  $amqp_host,
  $amqp_port,
  $qpid_protocol,
  $amqp_username,
  $amqp_password,
  $verbose,
  $heat_use_ssl = $quickstack::params::use_ssl_endpoints,
  $heat_key = $quickstack::params::heat_key,
  $heat_cert = $quickstack::params::heat_cert,
) {

  if str2bool_i($heat_use_ssl) {
      class {'moc_openstack::ssl::add_heat_cert':
      }
  }

  if str2bool_i("$ssl") {
    $sql_connection = "mysql://heat:${heat_db_password}@${mysql_host}/heat?ssl_ca=${mysql_ca}"
  } else {
    $sql_connection = "mysql://heat:${heat_db_password}@${mysql_host}/heat"
  }
  
  if str2bool_i($heat_use_ssl) {
    $heat_endpoint_protocol = "https"
  } else {
    $heat_endpoint_protocl = "http"
  }
  
  class {"::heat::keystone::auth":
      password         => $heat_user_password,
      public_address   => $controller_pub_host,
      admin_address    => $controller_priv_host,
      internal_address => $controller_priv_host,
      public_protocol  => $heat_endpoint_protocol,
      internal_protocol => $heat_endpoint_protocol,
      admin_protocol   => $heat_endpoint_protocol,
  }

  class {"::heat::keystone::auth_cfn":
      password         => $heat_user_password,
      public_address   => $controller_pub_host,
      admin_address    => $controller_priv_host,
      internal_address => $controller_priv_host,
      public_protocol  => $heat_endpoint_protocol,
      internal_protocol => $heat_endpoint_protocol,
      admin_protocol   => $heat_endpoint_protocol,
  }

  class { '::heat':
      keystone_host     => $controller_priv_host,
      keystone_password => $heat_user_password,
      auth_uri          => "https://${controller_priv_host}:5000/v2.0",
      identity_uri      => "https://${controller_priv_host}:35357",
      rpc_backend       => amqp_backend('heat', $amqp_provider),
      qpid_hostname     => $amqp_host,
      qpid_port         => $amqp_port,
      qpid_protocol     => $qpid_protocol,
      qpid_username     => $amqp_username,
      qpid_password     => $amqp_password,
      rabbit_host       => $amqp_host,
      rabbit_port       => $amqp_port,
      rabbit_userid     => $amqp_username,
      rabbit_password   => $amqp_password,
      rabbit_use_ssl    => $ssl,
      verbose           => $verbose,
      sql_connection    => $sql_connection,
  }

  if str2bool_i($heat_use_ssl) {
    class { '::heat::api_cfn':
        enabled => str2bool_i("$heat_cfn"),
        use_ssl => true,
        cert_file => $heat_cert,
        key_file  => $heat_key,
    }

    class { '::heat::api_cloudwatch':
        enabled => str2bool_i("$heat_cloudwatch"),
        use_ssl => true,
        cert_file => $heat_cert,
        key_file => $heat_key,
    }
  } else {
    class { '::heat::api_cfn':
        enabled => str2bool_i("$heat_cfn"),
    }

    class { '::heat::api_cloudwatch':
        enabled => str2bool_i("$heat_cloudwatch"),
    }
  }
  
  if str2bool_i($heat_use_ssl) {
    $protocol = "https"
  } else {
    $protocol = "http"
  }
  
  if $sahara_enabled {
    class { '::heat::engine':
      auth_encryption_key             => $auth_encryption_key,
      heat_metadata_server_url        => "${protocol}://${controller_priv_host}:8000",
      heat_waitcondition_server_url   => "${protocol}://${controller_priv_host}:8000/v1/waitcondition",
      heat_watch_server_url           => "${protocol}://${controller_priv_host}:8003",
      trusts_delegated_roles           => [''],
      configure_delegated_roles       => false,
    }
  } else {
    class { '::heat::engine':
      auth_encryption_key           => $auth_encryption_key,
      heat_metadata_server_url      => "${protocol}://${controller_priv_host}:8000",
      heat_waitcondition_server_url => "${protocol}://${controller_priv_host}:8000/v1/waitcondition",
      heat_watch_server_url         => "${protocol}://${controller_priv_host}:8003",
     }
  }

  # TODO: this ain't no place to be creating a db locally as happens below
  class { 'heat::db::mysql':
    password      => $heat_db_password,
    host          => $mysql_host,
    allowed_hosts => "%%",
  }

  if str2bool_i($heat_use_ssl) {
    class { '::heat::api':
      use_ssl  => true,
      cert_file => $heat_cert,
      key_file => $heat_key,
    }
  } else {
    class { '::heat::api':
    }
  }

  file { '/usr/lib/python2.7/site-packages/heat/common/context.py':
    notify => Service['openstack-heat-api', 'openstack-heat-engine'], # only restarts if change
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/quickstack/heat_context.py',
  }

}
