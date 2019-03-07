class profile::puppet_agent (

) {
  ini_setting { 'puppetmaster dns':
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'server',
    value   => 'puppet.test',
  }
}
