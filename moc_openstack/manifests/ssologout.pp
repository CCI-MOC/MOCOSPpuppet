class moc_openstack::ssologout {

  file { 'ssologout':
      ensure => 'file',
      content => template('moc_openstack/logout.erb'),
      path => '/var/www/html/logout.html',
      owner => 'root',
      group => 'root',
      mode  => '0644',
  }
}
