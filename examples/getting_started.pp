#############################################################################
# This is for placing in the getting started section of the README file.
#############################################################################
# Install Cassandra 2.2.5 onto a system and create a basic keyspace, table
# and index.  The node itself becomes a seed for the cluster.
#
# Tested on CentOS 7
#############################################################################

# Cassandra pre-requisites
include cassandra::datastax_repo
include cassandra::java

# Create a cluster called MyCassandraCluster which uses the
# GossipingPropertyFileSnitch.  In this very basic example
# the node itself becomes a seed for the cluster.
class { 'cassandra':
  authenticator   => 'PasswordAuthenticator',
  cluster_name    => 'MyCassandraCluster',
  endpoint_snitch => 'GossipingPropertyFileSnitch',
  listen_address  => $::ipaddress,
  seeds           => $::ipaddress,
  service_systemd => true,
  require         => Class['cassandra::datastax_repo', 'cassandra::java'],
}

class { 'cassandra::datastax_agent':
  settings => {
    'agent_alias'     => {
      'value' => 'foobar',
    },
    'stomp_interface' => {
       'value' => 'localhost',
    },
    'async_pool_size' => {
      ensure => absent,
    }
  }
}

class { 'cassandra::schema':
  cqlsh_password => 'cassandra',
  cqlsh_user     => 'cassandra',
  indexes        => {
    'users_lname_idx' => {
      table    => 'users',
      keys     => 'lname',
      keyspace => 'mykeyspace',
    },
  },
  keyspaces      => {
    'mykeyspace' => {
      durable_writes  => false,
      replication_map => {
        keyspace_class     => 'SimpleStrategy',
        replication_factor => 1,
      },
    }
  },
  tables         => {
    'users' => {
      columns  => {
        user_id       => 'int',
        fname         => 'text',
        lname         => 'text',
        'PRIMARY KEY' => '(user_id)',
      },
      keyspace => 'mykeyspace',
    },
  },
  users          => {
    'spillman' => {
      password => 'Niner27',
    },
    'akers'    => {
      password  => 'Niner2',
      superuser => true,
    },
    'boone'    => {
      password => 'Niner75',
    },
    'lucan'    => {
      ensure => absent
    },
  },
}

$heap_new_size = $::processorcount * 100

class { 'cassandra::env':
  file_lines => {
    'MAX_HEAP_SIZE' => {
      line              => 'MAX_HEAP_SIZE="1024M"',
      match             => '#MAX_HEAP_SIZE="4G"',
    },
    'HEAP_NEWSIZE' => {
      line              => "HEAP_NEWSIZE='${heap_new_size}M'",
      match             => '#HEAP_NEWSIZE="800M"',
    }
  }
}
