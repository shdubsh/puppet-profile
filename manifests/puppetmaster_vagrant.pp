class profile::puppetmaster_vagrant {
  file { '/etc/puppetlabs/code/environments/production':
    ensure  => 'link',
    target  => '/vagrant/',
    force   => true
  }

  Ini_setting {
    ensure  => present,
    section => 'master',
    path    => "/etc/puppetlabs/puppet/puppet.conf",
  }

  ini_setting { 'autosign':
    setting => 'autosign',
    value   => 'true'
  }

  ensure_packages('apt-transport-https')

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  include puppetdb::master::config
}
