class moc_openstack::nova_resize (
  $nova_priv_key    = "puppet:///modules/moc_openstack/nova/id_rsa",
  $authorized_keys  = "puppet:///modules/moc_openstack/nova/authorized_keys",
  $nova_ssh_config  = "puppet:///modules/moc_openstack/nova/config"
) {

  exec {'enable bash for nova':
    command => "usermod -s /bin/bash nova",
    path    => ['/usr/bin', '/usr/sbin',],
    require => Class[nova]
  } ->
  file {'/var/lib/nova/.ssh':
    ensure => 'directory',
    owner  => 'nova',
    group  => 'nova',
    mode   => '0700',
  } ->
  file {'/var/lib/nova/.ssh/id_rsa':
    ensure => present,
    mode   => '0600',
    owner  => 'nova',
    group  => 'nova',
    source => $nova_priv_key,
  } ->
  file {'/var/lib/nova/.ssh/authorized_keys':
    ensure => present,
    mode   => '0600',
    owner  => 'nova',
    group  => 'nova',
    source => $authorized_keys,
  } ->
  file {'/var/lib/nova/.ssh/config':
    ensure => present,
    mode   => '644',
    owner  => 'nova',
    group  => 'nova',
    source => $nova_ssh_config,
  }
}
