class profile::kibana (

) {
  include profile::elastic_common

  package {'kibana':
    ensure => 'present',
    require => Apt::Source['elastic']
  } ->
  file { '/etc/kibana/kibana.yml':
    ensure => 'present',
    source => "puppet:///modules/${module_name}/kibana/kibana.yml"
  } ->
  service { 'kibana':
    ensure => 'running'
  }

}