#
# == Class: openstack::keystone
#
# Installs and configures Keystone
#
# === Parameters
#
# [db_host] Host where DB resides. Optional. Defaults to 127.0.0.1..
# [idle_timeout] Timeout to reap SQL connections. Optional. Defaults to '200'.
# [db_password] Password for keystone DB. Required.
# [admin_token]. Auth token for keystone admin. Required.
# [admin_email] Email address of system admin. Required.
# [admin_password] Auth password for admin user. Required.
# [glance_user_password] Auth password for glance user. Required.
# [nova_user_password] Auth password for nova user. Required.
# [public_address] Public address where keystone can be accessed. Required.
# [public_protocol] Public protocol over which keystone can be accessed. Defaults to 'http'
# [token_format] Format keystone uses for tokens. Optional. Defaults to PKI.
#   Supports PKI and UUID.
# [db_type] Type of DB used. Currently only supports mysql. Optional. Defaults to  'mysql'
# [db_ssl] Boolean whether to use SSL for database. Defaults to false.
# [db_ssl_ca] If db_ssl is true, this is used in the connection to define the CA. Default undef.
# [db_user] Name of keystone db user. Optional. Defaults to  'keystone'
# [db_name] Name of keystone DB. Optional. Defaults to  'keystone'
# [admin_tenant] Name of keystone admin tenant. Optional. Defaults to  'admin'
# [verbose] Log verbosely. Optional. Defaults to false.
# [debug] Log at a debug-level. Optional. Defaults to false.
# [token_driver] Driver to use for managing tokens.
#   Optional.  Defaults to 'keystone.token.backends.sql.Token'
# [bind_host] Address that keystone binds to. Optional. Defaults to  '0.0.0.0'
# [internal_address] Internal address for keystone. Optional. Defaults to  $public_address
# [admin_address] Keystone admin address. Optional. Defaults to  $internal_address
# [glance] Set up glance endpoints and auth. Optional. Defaults to  true
# [nova] Set up nova endpoints and auth. Optional. Defaults to  true
# [swift] Set up swift endpoints and auth. Optional. Defaults to false
# [swift_user_password]
#   Auth password for swift.
#   (Optional) Defaults to false.
# [use_syslog] Use syslog for logging. Defaults to false.
# [log_facility] Syslog facility to receive log lines. Defaults to LOG_USER.
# [enabled] If the service is active (true) or passive (false).
#   Optional. Defaults to  true
#
# === Example
#
# class { 'openstack::keystone':
#   db_host               => '127.0.0.1',
#   db_password           => 'changeme',
#   admin_token           => '12345',
#   admin_email           => 'root@localhost',
#   admin_password        => 'changeme',
#   glance_user_password  => 'glance',
#   nova_user_password    => 'nova',
#   cinder_user_password  => 'cinder',
#   neutron_user_password => 'neutron',
#   public_address        => '192.168.1.1',
#  }

class openstack::keystone (
  $db_password,
  $admin_token,
  $admin_email,
  $admin_password,
  $public_address,
  $public_protocol             = 'http',
  $internal_protocol           = 'http',
  $admin_protocol              = 'http',
  $token_format                = 'UUID',
  $db_host                     = '127.0.0.1',
  $idle_timeout                = '200',
  $db_type                     = 'mysql',
  $db_user                     = 'keystone',
  $db_name                     = 'keystone',
  $db_ssl                      = false,
  $db_ssl_ca                   = undef,
  $admin_tenant                = 'admin',
  $verbose                     = false,
  $debug                       = false,
  $bind_host                   = '0.0.0.0',
  $region                      = 'RegionOne',
  $token_provider              = 'fernet',
  $token_driver                = 'sql',
  $internal_address            = false,
  $admin_address               = false,
  $enabled                     = true,
  $enable_ssl                  = false,
  $ssl_certfile                = '',
  $ssl_keyfile                 = '',
  $ssl_ca_certs                = '',
  $ssl_ca_key                  = '',
  $ssl_cert_subject            = '',

  #New for RHEL OSP Keystone
  $public_url	 	       = false,
  $internal_url 	       = false,
  $admin_url                   = false,

  $keystone_admin_url          = false,
  $keystone_priv_url           = false,
  $keystone_pub_url            = false,
  $nova_admin_url              = false,
  $nova_priv_url               = false,
  $nova_pub_url                = false,
  $nova_public_url_v3          = false,
  $nova_internal_url_v3        = false,
  $nova_admin_url_v3           = false,
  $glance_admin_url            = false,
  $glance_priv_url             = false,
  $glance_pub_url              = false,
  $neutron_admin_url           = false,
  $neutron_priv_url            = false,
  $neutron_pub_url             = false,
  $cinder_admin_url            = false,
  $cinder_priv_url             = false,
  $cinder_pub_url              = false,
  # nova
  $nova                        = true,
  $nova_user_password,
  $nova_public_address         = false,
  $nova_internal_address       = false,
  $nova_admin_address          = false,
  # glance
  $glance                      = true,
  $glance_user_password,
  $glance_public_address       = false,
  $glance_internal_address     = false,
  $glance_admin_address        = false,
  # cinder
  $cinder                      = true,
  $cinder_user_password,
  $cinder_public_address       = false,
  $cinder_internal_address     = false,
  $cinder_admin_address        = false,
  # neutron
  $neutron                     = true,
  $neutron_user_password,
  $neutron_public_address      = false,
  $neutron_internal_address    = false,
  $neutron_admin_address       = false,
  # ceilometer
  $ceilometer                  = true,
  $ceilometer_user_password,
  $ceilometer_public_address   = false,
  $ceilometer_internal_address = false,
  $ceilometer_admin_address    = false,
  # swift
  $swift                       = false,
  $swift_user_password         = false,
  $swift_public_address        = false,
  $swift_internal_address      = false,
  $swift_admin_address         = false,
  # heat
  $heat                        = false,
  $heat_user_password          = false,
  $heat_public_address         = false,
  $heat_internal_address       = false,
  $heat_admin_address          = false,
  # heat-cfn (cloudformation api)
  $heat_cfn                    = false,
  $heat_cfn_user_password      = false,
  $heat_cfn_public_address     = false,
  $heat_cfn_internal_address   = false,
  $heat_cfn_admin_address      = false,
  # logging
  $use_syslog                  = false,
  $log_facility                = 'LOG_USER'
) {

  # Install and configure Keystone
  if $db_type == 'mysql' {
    if $db_ssl == true {
      $sql_conn = "mysql://${db_user}:${db_password}@${db_host}/${db_name}?ssl_ca=${db_ssl_ca}"
    } else {
      $sql_conn = "mysql://${db_user}:${db_password}@${db_host}/${db_name}"
    }
  } else {
    fail("db_type ${db_type} is not supported")
  }

  # I have to do all of this crazy munging b/c parameters are not
  # set procedurally in Pupet
  if($internal_address) {
    $internal_real = $internal_address
  } else {
    $internal_real = $public_address
  }
  if($admin_address) {
    $admin_real = $admin_address
  } else {
    $admin_real = $internal_real
  }
  if($glance_public_address) {
    $glance_public_real = $glance_public_address
  } else {
    $glance_public_real = $public_address
  }
  if($glance_internal_address) {
    $glance_internal_real = $glance_internal_address
  } else {
    $glance_internal_real = $glance_public_real
  }
  if($glance_admin_address) {
    $glance_admin_real = $glance_admin_address
  } else {
    $glance_admin_real = $glance_internal_real
  }
  if($nova_public_address) {
    $nova_public_real = $nova_public_address
  } else {
    $nova_public_real = $public_address
  }
  if($nova_internal_address) {
    $nova_internal_real = $nova_internal_address
  } else {
    $nova_internal_real = $nova_public_real
  }
  if($nova_admin_address) {
    $nova_admin_real = $nova_admin_address
  } else {
    $nova_admin_real = $nova_internal_real
  }
  if($cinder_public_address) {
    $cinder_public_real = $cinder_public_address
  } else {
    $cinder_public_real = $public_address
  }
  if($cinder_internal_address) {
    $cinder_internal_real = $cinder_internal_address
  } else {
    $cinder_internal_real = $cinder_public_real
  }
  if($cinder_admin_address) {
    $cinder_admin_real = $cinder_admin_address
  } else {
    $cinder_admin_real = $cinder_internal_real
  }
  if($neutron_public_address) {
    $neutron_public_real = $neutron_public_address
  } else {
    $neutron_public_real = $public_address
  }
  if($neutron_internal_address) {
    $neutron_internal_real = $neutron_internal_address
  } else {
    $neutron_internal_real = $neutron_public_real
  }
  if($neutron_admin_address) {
    $neutron_admin_real = $neutron_admin_address
  } else {
    $neutron_admin_real = $neutron_internal_real
  }
  if($ceilometer_public_address) {
    $ceilometer_public_real = $ceilometer_public_address
  } else {
    $ceilometer_public_real = $public_address
  }
  if($ceilometer_internal_address) {
    $ceilometer_internal_real = $ceilometer_internal_address
  } else {
    $ceilometer_internal_real = $ceilometer_public_real
  }
  if($ceilometer_admin_address) {
    $ceilometer_admin_real = $ceilometer_admin_address
  } else {
    $ceilometer_admin_real = $ceilometer_internal_real
  }
  if($swift_public_address) {
    $swift_public_real = $swift_public_address
  } else {
    $swift_public_real = $public_address
  }
  if($swift_internal_address) {
    $swift_internal_real = $swift_internal_address
  } else {
    $swift_internal_real = $swift_public_real
  }
  if($swift_admin_address) {
    $swift_admin_real = $swift_admin_address
  } else {
    $swift_admin_real = $swift_internal_real
  }
  if($heat_public_address) {
    $heat_public_real = $heat_public_address
  } else {
    $heat_public_real = $public_address
  }
  if($heat_internal_address) {
    $heat_internal_real = $heat_internal_address
  } else {
    $heat_internal_real = $heat_public_real
  }
  if($heat_admin_address) {
    $heat_admin_real = $heat_admin_address
  } else {
    $heat_admin_real = $heat_internal_real
  }
  if($heat_cfn_public_address) {
    $heat_cfn_public_real = $heat_cfn_public_address
  } else {
    $heat_cfn_public_real = $public_address
  }
  if($heat_cfn_internal_address) {
    $heat_cfn_internal_real = $heat_cfn_internal_address
  } else {
    $heat_cfn_internal_real = $heat_cfn_public_real
  }
  if($heat_cfn_admin_address) {
    $heat_cfn_admin_real = $heat_cfn_admin_address
  } else {
    $heat_cfn_admin_real = $heat_cfn_internal_real
  }



  class { '::keystone':
    verbose        => $verbose,
    debug          => $debug,
    public_bind_host      => $bind_host,
    database_idle_timeout   => $idle_timeout,
    catalog_type   => 'sql',
    admin_token    => $admin_token,
    token_driver   => $token_driver,
    token_provider => $token_provider,
    #token_format   => $token_format,
    enabled        => $enabled,
    database_connection => $sql_conn,
    #sql_connection => $sql_conn,
    use_syslog     => $use_syslog,
    log_facility   => $log_facility,
    enable_ssl     => $enable_ssl,
    ssl_certfile   => $ssl_certfile,
    ssl_keyfile    => $ssl_keyfile,
    ssl_ca_certs   => $ssl_ca_certs,
  }

  if ($enabled) {
    # Setup the admin user
    class { 'keystone::roles::admin':
      email        => $admin_email,
      password     => $admin_password,
      admin_tenant => $admin_tenant,
    }

    # Setup the Keystone Identity Endpoint
    class { 'keystone::endpoint':
      public_url       => $public_url,
      admin_url        => $admin_url,
      internal_url     => $internal_url,
      #public_address  => $public_address,
      #Public protocol doesnt exist anymore, http:// added to address
      #public_protocol => $public_protocol,
      #admin_address   => $admin_real,
      #internal_address => $internal_real,
      region           => $region,
    }

    # Configure Glance endpoint in Keystone
    if $glance {
      class { 'glance::keystone::auth':
	public_url       => $glance_pub_url,
	admin_url        => $glance_admin_url,
	internal_url     => $glance_priv_url,
        password         => $glance_user_password,
        #Public protocol doesnt exist anymore, part of public_url
        #public_protocol => $public_protocol,
        #admin_address    => $glance_admin_real,
        #internal_address => $glance_internal_real,
        region           => $region,
      }
    }

    # Configure Nova endpoint in Keystone
    if $nova {
      class { 'nova::keystone::auth':
	public_url       => $nova_pub_url,
	admin_url        => $nova_admin_url,
	internal_url     => $nova_priv_url,
        public_url_v3    => $nova_public_url_v3,
        internal_url_v3  => $nova_internal_url_v3,
        admin_url_v3     => $nova_admin_url_v3,
        password         => $nova_user_password,
	# DEPRICATED
        #public_address   => $nova_public_real,
        #public_protocol  => $public_protocol,
        #admin_address    => $nova_admin_real,
        #internal_address => $nova_internal_real,
        region           => $region,
      }
    }

    # Configure Cinder endpoint in Keystone
    if $cinder {
      class { 'cinder::keystone::auth':
        password          => $cinder_user_password,
        public_address    => $cinder_public_real,
        public_url        => $cinder_pub_url,
        internal_url      => $cinder_priv_url,
        admin_url         => $cinder_admin_url,
        admin_address     => $cinder_admin_real,
        internal_address  => $cinder_internal_real,
        region            => $region,
      }
    }

    if $neutron {
      class { 'neutron::keystone::auth':
	public_url       => $neutron_pub_url,
	admin_url        => $neutron_admin_url,
	internal_url     => $neutron_priv_url,
        password         => $neutron_user_password,
	# DEPRICATED
        #public_address   => $neutron_public_real,
        #public_protocol  => $public_protocol,
        #admin_address    => $neutron_admin_real,
        #internal_address => $neutron_internal_real,
        region           => $region,
      }
    }

    if $ceilometer {

      if ! $ceilometer_user_password {
        fail('Must set a ceilometer_user_password when ceilometer auth is being configured')
      }

      class { 'ceilometer::keystone::auth':
        password         => $ceilometer_user_password,
        public_address   => $ceilometer_public_real,
#       public_protocol  => $public_protocol,
        admin_address    => $ceilometer_admin_real,
        internal_address => $ceilometer_internal_real,
        region           => $region,
      }
    }

    if $swift {

      if ! $swift_user_password {
        fail('Must set a swift_user_password when swift auth is being configured')
      }

      class { 'swift::keystone::auth':
        password         => $swift_user_password,
        public_address   => $swift_public_real,
        public_protocol  => $public_protocol,
        admin_address    => $swift_admin_real,
        internal_address => $swift_internal_real,
        region           => $region,
      }
    }

    if $heat {

      if ! $heat_user_password {
        fail('Must set a heat_user_password when heat auth is being configured')
      }

      class { 'heat::keystone::auth':
        password         => $heat_user_password,
        public_address   => $heat_public_real,
        public_protocol  => $public_protocol,
        admin_address    => $heat_admin_real,
        internal_address => $heat_internal_real,
        region           => $region,
      }
    }

    if $heat_cfn {

      if ! $heat_cfn_user_password {
        fail('Must set a heat_cfn_user_password when heat_cfn auth is being configured')
      }

      class { 'heat::keystone::auth_cfn':
        password         => $heat_cfn_user_password,
        public_address   => $heat_cfn_public_real,
        public_protocol  => $public_protocol,
        admin_address    => $heat_cfn_admin_real,
        internal_address => $heat_cfn_internal_real,
        region           => $region,
      }
    }



  }



}
