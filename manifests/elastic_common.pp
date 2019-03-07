class profile::elastic_common (

) {
  if (! defined(Package['apt-transport-https'])) {
    package { 'apt-transport-https':
      ensure => 'present'
    }
  }

  apt::source { 'elastic':
    location => 'https://artifacts.elastic.co/packages/6.x/apt',
    repos    => 'main',
    release  => 'stable',
    key      => {
      'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
      'server' => 'https://artifacts.elastic.co',
      'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
    },
  }
}