class profile::logstash (

) {
  include profile::elastic_common

  package { 'logstash':
    ensure => 'present',
    require => Apt::Source['elastic']
  }

  file { '/etc/logstash/conf.d/10-input.conf':
    ensure => 'present',
    source => "puppet:///modules/${module_name}/logstash/10-input.conf",
    require => Package['logstash'],
    notify => Exec['restart logstash']
  }

  file { '/etc/logstash/conf.d/90-output.conf':
    ensure => 'present',
    source => "puppet:///modules/${module_name}/logstash/90-output.conf",
    require => Package['logstash'],
    notify => Exec['restart logstash']
  }

  file { '/etc/logstash/elasticsearch-template.json':
    ensure => 'present',
    source => "puppet:///modules/${module_name}/logstash/elasticsearch-template.json",
    require => Package['logstash'],
    notify => Exec['restart logstash']
  }

  service { 'logstash':
    ensure => 'running'
  }

  exec { 'restart logstash':
    command => '/bin/systemctl restart logstash',
    refreshonly => true
  }

}
