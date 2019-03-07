class profile::elasticsearch (

) {
  include profile::elastic_common

  package { 'openjdk-8-jre':
    ensure => 'present'
  } ->
  package { 'elasticsearch':
    ensure => 'present',
    require => Apt::Source['elastic']
  } ->
  service { 'elasticsearch':
    ensure => 'running'
  }
}
