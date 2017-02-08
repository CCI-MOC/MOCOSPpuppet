class moc_openstack::ssl::install_rootca (
  $rootCA_crt       = '/etc/pki/ca-trust/source/anchors/rootCA.crt',
  $rootCA_crt_path  = 'puppet:///modules/moc_openstack/certs/rootCA.crt',
  $trusted_store    = '/etc/pki/tls/certs/ca-bundle.crt',
) {

  file {$rootCA_crt:
    ensure => present,
    mode => '0644',
    owner => 'root',
    group => 'root',
    # do not overwrite the file again
    replace => false,
    source => $rootCA_crt_path,
    notify => Exec['add-ca-truststore'],
  }

  package { "python-requests":
    ensure => present,
  }

  package { "python-pip":
    ensure => present,
  }

#  exec { "update-urllib3":
    # used urllib3 version 1.11 since there was bug in 1.10.4 which ignored
    # signed certs by rootCA. Version 1.11 introduced various issues with glance.
    # Hence, commented it out and used version 1.10.2 which worked fine.
    #command   => "/bin/pip install urllib3[secure] --upgrade",
#    command   => "/bin/pip install urllib3==1.10.2",
#    require   => Package['python-requests','python-pip'],
#  }

  # appends rootCA.crt to end of trusted certs.
  # python-requests use the CA file at trusted_store.
  exec { 'add-ca-truststore':
    command     => "/bin/cat ${rootCA_crt} >> ${trusted_store}",
    require     => File[$rootCA_crt],
    # makes sure its executed only when it
    # receives notification for rootCA.crt creation.
    refreshonly => true,
  }
}
