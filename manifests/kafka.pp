class profile::kafka (

) {
  if (! defined(Package['apt-transport-https'])) {
    package { 'apt-transport-https':
      ensure => 'present'
    }
  }

  # Java starts with the hosts file when resolving what to bind to
  # This will force it to the external IP
  host { 'kafka.test':
    host_aliases => [ 'kafka' ],
    ip => $::ipaddress
  }

  apt::source { 'confluent':
    location => 'https://packages.confluent.io/deb/5.1',
    repos    => 'main',
    release  => 'stable',
    key      => {
      'id'     => '1A77041E0314E6C5A486524E670540C841468433',
      'server' => 'https://packages.confluent.io',
      'source' => 'https://packages.confluent.io/deb/5.1/archive.key',
    },
  }

  package { 'openjdk-8-jre':
    ensure => 'present'
  }

  package { 'confluent-community-2.11':
    ensure => 'present',
    require => [ Apt::Source['confluent'], Package['openjdk-8-jre'] ]
  }

  file { '/etc/kafka/zookeeper.properties':
    ensure => 'present',
    source => "puppet:///modules/${module_name}/kafka/zookeeper.properties",
    require => Package['confluent-community-2.11']
  }

  file { '/etc/kafka/server.properties':
    ensure => 'present',
    source => "puppet:///modules/${module_name}/kafka/server.properties",
    require => Package['confluent-community-2.11']
  }

  service { 'confluent-zookeeper':
    ensure => 'running',
    require => [ File['/etc/kafka/zookeeper.properties'] ]
  }

  service { 'confluent-kafka':
    ensure => 'running',
    require => [ Service['confluent-zookeeper'], File['/etc/kafka/server.properties'] ]
  }

  # Confluent repo has a "newer" version that depends on libssl1.0.0 not available in stretch
  apt::pin { 'librdkafka1 from stretch':
    packages => 'librdkafka1',
    codename => 'stretch',
    priority => 1000
  }

  package { 'kafkacat':
    ensure => 'present',
    require => [ Apt::Pin['librdkafka1 from stretch'] ]
  }
}
