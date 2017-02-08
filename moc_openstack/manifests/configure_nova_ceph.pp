# Configures nova to talk to ceph 
# This is specific to  compute node
class moc_openstack::configure_nova_ceph($nova_uuid, $ceph_key, $ceph_user) {
  if $::osfamily == 'RedHat' {
    file { "/etc/nova/secret.xml":
      path => "/etc/nova/secret.xml",
      ensure => present,
      owner => root,
      group => root,
      mode => 755,
      content => template('moc_openstack/novasecret.erb')
    } ->
    exec{"Executing virsh commands":
     require => File["/etc/nova/secret.xml"],
     command => "/usr/bin/virsh secret-define --file /etc/nova/secret.xml;/usr/bin/virsh secret-set-value --secret $nova_uuid --base64 $ceph_key",
     #onlyif  => "/usr/bin/test ! -f /etc/nova/secret.xml",
    }
} else {
    fail("The configure_nova_ceph module is only supported on RedHat systems!")
  }
}
