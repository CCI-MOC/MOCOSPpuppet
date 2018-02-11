# This requires puppetlabs openstack module
# and puppetlabs/firewall module
#
# generic wrapper for config options not exposed
# in openstack module
#
# basic port filtering because openstack doesn't belive in application
# security in a lot of ways...
class moc_openstack::firewall (
  $interface = 'enp130s0f0', # note we dont want to get in the way of Neutron iptables
  $public_net  = undef,
  $private_net = undef,
)
{
  if hiera('moc::enablefirewall') == 'true' {
    include ::firewall
    # for a million reasons we should be collecting a list of
    # controllers and compute hosts, when we do we should iterate here
    firewall { '001 allow internal openstacknet':
      chain    => 'INPUT',
      proto    => 'all',
      source   => $private_net,
      action   => 'accept',
    }
    firewall { '002 allow internal mgmt subnet':
      chain    => 'INPUT',
      proto    => 'all',
      source   => $quickstack::params::surnet2,
      action   => 'accept',
    }
    firewall { '010 accept all icmp':
      proto   => 'icmp',
      action  => 'accept',
    }
    firewall { '011 allow ssh':
      proto  => 'tcp',
      dport  => '22',
      action => 'accept',
    }
    firewall { '099 accept related established rules':
      proto   => 'all',
      state => ['RELATED', 'ESTABLISHED'],
      action  => 'accept',
    }
    # should execept all from ::management_stations
#    hiera('management_stations').each |$station| {
#      firewall { "100 allow management station ${station}":
#        chain    => 'INPUT',
#        iniface  => $interface,
#        source   => "${station}/32",
#        action   => 'accept',      
#      }
#    }
#    # should accept ssh from ::local_netblocks
#    hiera('local_netblocks').each |$net| {
#      firewall { "110 allow ssh local net ${net}":
#        chain    => 'INPUT',
#        iniface  => $interface,
#        proto    => 'tcp',
#        dport    => '22',
#        source   => $net,
#        action   => 'accept',      
#      }
#    }
    firewall { '995 allow loopback traffic':
      chain => 'INPUT',
      source => '127.0.0.0/8',
      action => 'accept',
    }
    firewall { '996 drop all incoming ipv6 traffic':
      chain    => 'INPUT',
      action   => 'drop',
      provider => 'ip6tables',
    }
    firewall { '997 drop all outgoing ipv6 traffic':
      chain    => 'OUTPUT',
      action   => 'drop',
      provider => 'ip6tables',
    }
    firewall { '998 no forwarding of ipv6 traffic':
      chain    => 'FORWARD',
      action   => 'drop',
      provider => 'ip6tables',
    }
    firewall { '999 drop all':
      require  => Firewall['001 allow internal openstacknet'],
      chain    => 'INPUT',
      proto    => 'all',
      action   => 'drop',
    }
  }
}
