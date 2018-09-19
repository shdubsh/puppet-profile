class profile::icinga (
  $users                  = ['icingaadmin'],
  $cfg_files              = [],
  $cfg_dirs               = [],
  $contactgroups          = {},
  $max_concurrent_checks  = 10000,
  $service_check_timeout  = 90,
  $enable_notifications   = 0,
  $enable_event_handlers  = 1,
  $icinga_user            = 'nagios',
  $icinga_group           = 'nagios'
) {
  ensure_packages('icinga')

  file { '/etc/icinga/cgi.cfg':
    content => template("${module_name}/icinga/cgi.cfg.erb"),
    mode    => '0644',
    owner   => $icinga_user,
    group   => $icinga_group,
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/icinga.cfg':
    content => template("${module_name}/icinga/icinga.cfg.erb"),
    mode    => '0644',
    owner   => $icinga_user,
    group   => $icinga_group,
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/ncsa_frack.cfg':
    source  => "puppet:///modules/${module_name}/icinga/ncsa_frack.cfg",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0644',
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/contactgroups.cfg':
    content   => template("${module_name}/icinga/contactgroups.cfg.erb"),
    mode      => '0644',
    owner     => $icinga_user,
    group     => $icinga_group,
    show_diff => false,
    require   => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { "/etc/icinga/contacts.cfg":
    content   => template("${module_name}/icinga/contacts.cfg.erb"),
    owner     => $icinga_user,
    group     => $icinga_group,
    mode      => '0600',
    show_diff => false,
    require   => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/resource.cfg':
    source  => "puppet:///modules/${module_name}/icinga/resource.cfg",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0644',
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/timeperiods.cfg':
    source  => "puppet:///modules/${module_name}/icinga/timeperiods.cfg",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0644',
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/notification_commands.cfg':
    source  => "puppet:///modules/${module_name}/icinga/notification_commands.cfg",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0644',
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }
}
