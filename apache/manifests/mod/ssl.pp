class apache::mod::ssl (
  $ssl_compression         = false,
  $ssl_cryptodevice        = 'builtin',
  $ssl_options             = [ 'StdEnvVars' ],
  $ssl_openssl_conf_cmd    = undef,
  $ssl_cipher              = '"EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4"',
  $ssl_honorcipherorder    = 'On',
  $ssl_protocol            = [ 'all', '-SSLv2', '-SSLv3' ],
  $ssl_pass_phrase_dialog  = 'builtin',
  $ssl_random_seed_bytes   = '512',
  $ssl_sessioncachetimeout = '300',
  $apache_version          = $::apache::apache_version,
  $package_name            = undef,
) {
  $session_cache = $::osfamily ? {
    'debian'  => "\${APACHE_RUN_DIR}/ssl_scache(512000)",
    'redhat'  => '/var/cache/mod_ssl/scache(512000)',
    'freebsd' => '/var/run/ssl_scache(512000)',
    'gentoo'  => '/var/run/ssl_scache(512000)',
  }

  case $::osfamily {
    'debian': {
      if versioncmp($apache_version, '2.4') >= 0 {
        $ssl_mutex = 'default'
      } elsif $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '10.04' {
        $ssl_mutex = 'file:/var/run/apache2/ssl_mutex'
      } else {
        $ssl_mutex = "file:\${APACHE_RUN_DIR}/ssl_mutex"
      }
    }
    'redhat': {
      $ssl_mutex = 'default'
    }
    'freebsd': {
      $ssl_mutex = 'default'
    }
    'gentoo': {
      $ssl_mutex = 'default'
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }

  ::apache::mod { 'ssl':
    package => $package_name,
  }

  if versioncmp($apache_version, '2.4') >= 0 {
    ::apache::mod { 'socache_shmcb': }
  }

  # Template uses
  #
  # $ssl_compression
  # $ssl_cryptodevice
  # $ssl_cipher
  # $ssl_honorcipherorder
  # $ssl_options
  # $ssl_openssl_conf_cmd
  # $session_cache
  # $ssl_mutex
  # $ssl_random_seed_bytes
  # $ssl_sessioncachetimeout
  # $apache_version
  #
  file { 'ssl.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/ssl.conf",
    content => template('apache/mod/ssl.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

#  file { '/etc/httpd/conf.d/wsgi-keystone.conf':
#    ensure  => file,
#    path    => "${::apache::mod_dir}/wsgi-keystone.conf",
#    content => template('keystone/wsgi-keystone.erb'),
#    require => Exec["mkdir ${::apache::mod_dir}"],
#    before  => File[$::apache::mod_dir],
#    notify  => Class['apache::service'],
#  }
}
