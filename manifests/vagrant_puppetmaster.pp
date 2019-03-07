class profile::vagrant_puppetmaster (

) {
  include profile::puppetmaster

  file { '/etc/puppetlabs/code/environments/production':
    ensure  => 'link',
    target  => '/vagrant/',
    force   => true
  }

  ini_setting { "autosign":
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => 'true',
  }

  ensure_packages('apt-transport-https')

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  include puppetdb::master::config

  cron { 'regenerate zonefile':
    command => '/usr/bin/python3 /usr/local/bin/zonefile_generator | sudo tee /etc/coredns/zones/test && sudo systemctl reload coredns',
    minute  => '*'
  }
}
