class quickstack::params (
  $scenarii,
  $scenario,
  
  # Logs
  $admin_email,
  $verbose,
  
  $heat_cfn,
  $heat_cloudwatch,
  
  # Passwords are currently changed to decent strings by sed
  # during the setup process. This will move to the Foreman API v2
  # at some point.
  $admin_password,
  $ceilometer_metering_secret,
  $ceilometer_user_password,
  $heat_user_password,
  $heat_db_password,
  $horizon_secret_key,
  $keystone_admin_token,
  $keystone_db_password,
  $mysql_root_password,
  $neutron_db_password,
  $neutron_user_password,
  $nova_db_password,
  $nova_user_password,

  # Ceph parameters
  $ceph_nodes,
  $ceph_endpoints,
  $ceph_user,
  $nova_uuid,
  $ceph_key,

  # Keystone Endpoints
  # Kilo keystone now needs fully quallified urls
  # Instead of old IP / Port as seperate params
  # keystone
  $auth_uri,
  $identity_uri,
  $keystone_pub_url,
  $keystone_priv_url,
  $keystone_admin_url,
  $auth_protocol,
  # nova
  $nova_pub_url,
  $nova_priv_url,
  $nova_admin_url,
  $nova_public_url_v3,
  $nova_internal_url_v3,
  $nova_admin_url_v3,
  # glance
  $glance_pub_url,
  $glance_priv_url,
  $glance_admin_url,
  # ceilometer
  $ceilometer_public_real,
  $ceilometer_internal_real,
  $ceilometer_admin_real,
  $enable_ceilometer,
  # cinder
  $cinder_pub_url,
  $cinder_priv_url,
  $cinder_admin_url,
  # neutron
  $neutron_pub_url,
  $neutron_priv_url,
  $neutron_admin_url,
  # swift
  $swift_pub_url,
  $swift_priv_url,
  $swift_admin_url, 
  
  # Cinder
  $cinder_db_password,
  $cinder_user_password,
  # Cinder backend - Several backends should be able to coexist
  $cinder_backend_gluster,
  $cinder_backend_gluster_name,
  $cinder_backend_iscsi,
  $cinder_backend_iscsi_name,
  $cinder_backend_nfs,
  $cinder_backend_nfs_name,
  $cinder_backend_dell_sc,
  $cinder_backend_dell_sc_name,
  $cinder_backend_eqlx,
  $cinder_backend_eqlx_name,
  $cinder_backend_netapp,
  $cinder_multiple_backends,
  $cinder_backend_rbd,
  $cinder_backend_rbd_name,
  # Cinder gluster
  $cinder_gluster_volume,
  $cinder_gluster_path,
  $cinder_gluster_peers,
  $cinder_gluster_replica_count,
  $cinder_glusterfs_shares,
  # Cinder nfs
  $cinder_nfs_shares,
  $cinder_nfs_mount_options,
  # Cinder Dell Storage Center ISCSI
  $cinder_dell_sc_san_ip,
  $cinder_dell_sc_san_login,
  $cinder_dell_sc_san_password,
  $cinder_dell_sc_iscsi_ip_address,
  $cinder_dell_sc_iscsi_port,
  $cinder_dell_sc_ssn,
  $cinder_dell_sc_api_port,
  $cinder_dell_sc_server_folder,
  $cinder_dell_sc_volume_folder,
  # Cinder Dell EqualLogic
  $cinder_san_ip,
  $cinder_san_login,
  $cinder_san_password,
  $cinder_san_thin_provision,
  $cinder_eqlx_group_name,
  $cinder_eqlx_pool,
  $cinder_eqlx_use_chap,
  $cinder_eqlx_chap_login,
  $cinder_eqlx_chap_password,
  #  Cinder NetApp
  $cinder_netapp_hostname,
  $cinder_netapp_login,
  $cinder_netapp_password,
  $cinder_netapp_server_port,
  $cinder_netapp_storage_family,
  $cinder_netapp_transport_type,
  $cinder_netapp_storage_protocol,
  $cinder_netapp_nfs_shares,
  $cinder_netapp_nfs_shares_config,
  $cinder_netapp_volume_list,
  $cinder_netapp_vfiler,
  $cinder_netapp_vserver,
  $cinder_netapp_controller_ips,
  $cinder_netapp_sa_password,
  $cinder_netapp_storage_pools,
  ## SIZE FUNCTION BREAKING PUPPET, COMMENTING OUT
  # $cinder_backend_netapp_name      = produce_array_with_prefix("netapp", 1, size($cinder_netapp_hostname)),
  #  Cinder RBD
  $cinder_rbd_pool,
  $cinder_perf_rbd_pool = undef,
  $libvirt_rbd_pool,
  $cinder_rbd_ceph_conf,
  $cinder_rbd_flatten_volume_from_snapshot,
  $cinder_rbd_max_clone_depth,
  $cinder_rbd_user,
  $cinder_rbd_secret_uuid,
  
  # Glance
  $glance_db_password,
  $glance_user_password,
  $glance_backend,
  
  # Glance RBD
  $glance_rbd_store_user,
  $glance_rbd_store_pool,
  
  # Glance_Gluster
  $glance_gluster_volume,
  $glance_gluster_path,
  $glance_gluster_peers,
  $glance_gluster_replica_count,
  
  # Gluster
  $gluster_open_port_count,
  
  # Networking
  $neutron,
  $controller_admin_host,
  $controller_admin_url,
  $controller_priv_host,
  $controller_priv_url,
  $controller_pub_host,
  $controller_pub_url,
  $nova_default_floating_pool,
  
  # Nova-network specific
  $fixed_network_range,
  $floating_network_range,
  $auto_assign_floating_ip,
  
  # Neutron specific
  $neutron_metadata_proxy_secret,
  
  $mysql_host,
  $amqp_provider,
  $amqp_host,
  $amqp_username,
  $amqp_password,
  $enable_ovs_agent,
  $tenant_network_type,
  $ovs_vlan_ranges,
  $ovs_bridge_mappings,
  $ovs_bridge_uplinks,
  $configure_ovswitch,
  $enable_tunneling,
  $ovs_vxlan_udp_port,
  $ovs_tunnel_types,
  $ovs_tunnel_iface, 
  $network_device_mtu,
  $veth_mtu,

  # ssl certificates
  $root_ca_cert,
  $horizon_key,
  $horizon_cert,
  $nova_key,
  $nova_cert,
  $keystone_key,
  $keystone_cert,
  $cinder_key,
  $cinder_cert,
  $glance_key,
  $glance_cert,
  $neutron_key,
  $neutron_cert,
  $heat_key,
  $heat_cert,
  $sahara_key,
  $sahara_cert,

  # neutron plugin config
  $neutron_core_plugin,
  # If using the Cisco plugin, use either OVS or n1k for virtualised l2
  $cisco_vswitch_plugin,
  # If using the Cisco plugin, Nexus hardware can be used for l2
  $cisco_nexus_plugin,
  $agent_type,
  
  # If using the nexus sub plugin, specify the hardware layout by
  # using the following syntax:
  # $nexus_config = { 'SWITCH_IP' => { 'COMPUTE_NODE_NAME' : 'PORT' } },
  $nexus_config,
  
  # Set the nexus login credentials by creating a list
  # of switch_ip/username/password strings as per the example below:
  $nexus_credentials,
  
  $n1kv_vsm_ip,
  $n1kv_vsm_password,
  #$neutron_conf_additional_params,
  #$nova_conf_additional_params,
  #$n1kv_plugin_additional_params,
  $security_group_api,
  $neutron_conf_additional_params = { 'default_quota' => 'default',
                             'quota_network' => 'default',
                             'quota_subnet' => 'default',
                             'quota_port' => 'default',
                             'quota_security_group' => 'default',
                             'quota_security_group_rule' => 'default',
                             'quota_vip' => 'default',
                             'quota_pool' => 'default',
                             'quota_router' => 'default',
                             'quota_floatingip' => 'default',
                             'network_auto_schedule' => 'default'
                           },
  $nova_conf_additional_params = { 'quota_instances' => 'default',
                             'quota_cores' => 'default',
                             'quota_ram' => 'default',
                             'quota_floating_ips' => 'default',
                             'quota_fixed_ips' => 'default',
                             'quota_driver' => 'default',
                             },
  $n1kv_plugin_additional_params = { 'default_policy_profile' => 'default-pp',
                             'network_node_policy_profile' => 'default-pp',
                             'poll_duration' => '10',
                             'http_pool_size' => '4',
                             'http_timeout' => '30',
                             'firewall_driver' => 'neutron.agent.firewall.NoopFirewallDriver',
                             'enable_sync_on_start' => 'True',
                             'restrict_policy_profiles' => 'False',
                             },
  # Horizon
  
  $django_debug,
  $help_url,
  $cache_server_ip,
  $cache_server_port,
  $keystone_port,
  $keystone_scheme,
  $keystone_default_role,
  $can_set_mount_point,
  $api_result_limit,
  $log_level,
  $horizon_app_links,
  $support_profile,

  # Heat
  $heat_auth_encrypt_key,

  # provider network settings
  $provider_vlan_auto_create,
  $provider_vlan_auto_trunk,
  $mysql_virt_ip_nic,
  $mysql_virt_ip_cidr_mask,
  $mysql_shared_storage_device,
  $mysql_shared_storage_options,
  # e.g. "nfs"
  $mysql_shared_storage_type,
  $mysql_clu_member_addrs,
  $mysql_resource_group_name,
  
  # SSL
  $ssl,
  $use_ssl_endpoints,
  $mysql_ssl,
  $amqp_ssl,
  $horizon_ssl,
  $freeipa,
  $mysql_ca,
  $mysql_cert,
  $mysql_key,
  $amqp_ca,
  $amqp_cert,
  $amqp_key,
  $horizon_ca,
  $horizon_cert,
  $horizon_key,
  $amqp_nssdb_password,
  
  # Pacemaker
  $pacemaker_cluster_name,
  $pacemaker_cluster_members,
  $ha_loadbalancer_public_vip,
  $ha_loadbalancer_private_vip,
  $ha_loadbalancer_group,
  $fencing_type,
  $fence_xvm_clu_iface,
  $fence_xvm_manage_key_file,
  $fence_xvm_key_file_password,
  $fence_ipmilan_address,
  $fence_ipmilan_username,
  $fence_ipmilan_password,
  $fence_ipmilan_interval,
  
  # Gluster Servers
  $gluster_device1,
  $gluster_device2,
  $gluster_device3,
  $gluster_fqdn1,
  $gluster_fqdn2,
  $gluster_fqdn3,
  # One port for each brick in a volume
  $gluster_port_count,
  $gluster_replica_count,
  $gluster_uuid1,
  $gluster_uuid2,
  $gluster_uuid3,
  $gluster_volume1_gid,
  $gluster_volume1_name,
  $gluster_volume1_path,
  $gluster_volume1_uid,
  $gluster_volume2_gid,
  $gluster_volume2_name,
  $gluster_volume2_path,
  $gluster_volume2_uid,
  $gluster_volume3_gid,
  $gluster_volume3_name,
  $gluster_volume3_path,
  $gluster_volume3_uid,

  # sensu server
  $sensu_client_enable,
  $sensu_rabbitmq_host,
  $sensu_rabbitmq_user,
  $sensu_rabbitmq_password,
  $sensu_subscriptions_compute,
  $sensu_subscriptions_controller,
  $sensu_handlers_compute,
  $sensu_handlers_controller,
  $redact,
  $client_custom,

  # Firewall
  $public_net,
  $private_net,
  $controller_private_ip,

  #NTP
  $ntp_public_servers,
  $ntp_local_servers,

  #moc allowed users
  $moc_users,
  
  #backups
  $backups_user,
  $backups_directory,
  $backups_log,
  $backups_verbose,
  $backups_email,
  $backups_ssh_key,
  $backups_sudoers_d,
  $backups_script_controller,
  $backups_script_compute,
  $backups_script_local_name,
  $backups_local_hour,
  $backups_local_min, 
  $backups_keep_days,
  $backups_enabled,

  $elasticsearch_host,

  # Allow instance resize
  $allow_resize,
  $allow_migrate,

  # repo server
  $repo_server,

  # interface configuration
  $lenovo_pub_iface,
  $lenovo_priv_iface,
  $lenovo_ceph_iface,
  $quanta_pub_iface,
  $quanta_priv_iface,
  $quanta_ceph_iface,
  $default_pub_iface,
  $default_priv_iface,
  $default_ceph_iface,
  $pub_vlan,
  $pub_netmask,
  $priv_netmask,
  $pub_net,
  $pub_ip,
  $priv_net,
  $ceph_net,
  $ceph_vlan,
  $ceph_netmask,

  # ceilometer parameters
  $ceilometer_url,
  $ceilometer_db,
  $ceilometer_auth_uri,
  $ceilometer_identity_uri,
  $ceilometer_password,
  $ceilometer_auth_host,
  $ceilometer_keystone_user,
  $ceilometer_keystone_tenant,
  $ceilometer_rabbit_port,
  $ceilometer_auth_url,
  $ceilometer_backend,

  # Sahara
  $sahara_enabled,
  $sahara_password,
  $sahara_db_password,
  $sahara_debug,
  $heat_domain_password,
  $sahara_plugins,
  $sahara_manage_policy,
) {
}
