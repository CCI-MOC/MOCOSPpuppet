#####################################################################
# Name: cronjob.pp
#
# Descr:-
# This file updates the repos present on the nodes. It makes sure
# that proper repos are present on the nodes and disables others.
# It also adds yum-cron.
#
#####################################################################

class moc_openstack::cronjob (
  $base_dir  = '/etc/yum.repos.d/',
  $repo_server = '127.0.0.1',
  $randomwait = 180,
) {

  if $::environment == 'production' {
    $rhel7_file_path = "${base_dir}rhel7local-prod.repo"
    $epel_file_path = "${base_dir}epel7local-prod.repo"
    $suricata_file_path = "${base_dir}suricata7local-prod.repo"
    $rhel7_link = "http://${repo_server}/repos/rhel7local-prod.repo"
    $epel_link = "http://${repo_server}/repos/epel7local-prod.repo"
    $suricata_link = "http://${repo_server}/repos/suricata7local-prod.repo"
  } else {
    $rhel7_file_path = "${base_dir}rhel7local.repo"
    $epel_file_path = "${base_dir}epel7local.repo"
    $suricata_file_path = "${base_dir}suricata7local.repo"
    $rhel7_link = "http://${repo_server}/repos/rhel7local.repo"
    $epel_link = "http://${repo_server}/repos/epel7local.repo"
    $suricata_link = "http://${repo_server}/repos/suricata7local.repo"
  }

  # backup the original redhat.repo before puppet run
#  exec {'backup_redhat_repo':
#    onlyif  => "/bin/test -f ${base_dir}redhat.repo",
#    command => "/bin/cp ${base_dir}redhat.repo ${base_dir}redhat.repo.default",
#  } ->
#  exec {'disable_redhat_repos':
#    onlyif  => "/bin/test -f ${base_dir}redhat.repo",
#    command => "/bin/sed -i '/enabled/c\enabled = 0 ' ${base_dir}redhat.repo",
#  } ->
#  exec {'disable_epel_repos':
#    onlyif  => "/bin/test -f ${base_dir}epel.repo",
#    command => "/bin/sed -i '/enabled/c\enabled = 0 ' ${base_dir}epel.repo",
#  } ->
#  exec {'disable_epel_testing_repos':
#    onlyif  => "/bin/test -f ${base_dir}epel-testing.repo",
#    command => "/bin/sed -i '/enabled/c\enabled = 0 ' ${base_dir}epel-testing.repo",
#  } ->

  # update repos if something has changed. -N checks if the file's
  # timestamp has changed. If yes, it downloads it. 
  exec {'update_rhel7_file':
    command => "/usr/bin/grep -i centos /etc/redhat-release || /bin/wget -q -N $rhel7_link -P ${base_dir}",
  } ->
  exec {'update_epel_file':
    command => "/bin/wget -q -N $epel_link -P ${base_dir}",
  } ->
  exec {'update_suricata_file':
    command => "/bin/wget -q -N $suricata_link -P ${base_dir}",
  }

  class { 'yum_cron':
    enable           => true,
    download_updates => true,
    apply_updates    => true,
    randomwait       => $randomwait,
  }
  file { '/etc/cron.daily/1new-kernel-reboot':
    ensure => 'file',
    content => template('moc_openstack/1new-kernel-reboot.erb'),
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

}
