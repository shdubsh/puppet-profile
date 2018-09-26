class profile::icinga (
  $virtual_host = 'icinga.test',
  $monitoring_groups = {}
) {
  include icinga
  include nsca::daemon
  include monitoring::monitor::frack
  include monitoring::monitor::checkpaging
  include monitoring::monitor::wikidata
  include monitoring::monitor::ores
  include monitoring::monitor::toollabs
  include monitoring::monitor::legal
  include monitoring::monitor::certs
  include monitoring::monitor::gsb
  include monitoring::monitor::commons
  include monitoring::monitor::wdqs
  include monitoring::monitor::performance
  include monitoring::monitor::services
  include monitoring::monitor::reading_web
  include monitoring::monitor::traffic

  # Required for integration with monitoring module
  file { '/etc/nagios':
    ensure => directory
  }

  file { [ '/etc/nagios/nagios_host.cfg', '/etc/nagios/nagios_service.cfg' ]:
    ensure => 'file',
    mode => '0444'
  }

  # TODO: this should probably be in monitoring included in base
  # @monitoring::group { "${role}_${datacenter}":
  #   description => "${role}_${datacenter} host and service group"
  # }

  create_resources(monitoring::group, $monitoring_groups)

  # TODO: Should probably be moved to monitoring module
  # Check that the icinga config is sane
  monitoring::service { 'check_icinga_config':
    group          => "${role}_${datacenter}",
    description    => 'Check correctness of the icinga configuration',
    check_command  => 'check_icinga_config',
    check_interval => 10,
  }

  # IRC Echo Resources
  $ircecho_logs   = {
    '/var/log/icinga/irc.log'             => '#wikimedia-operations',
    '/var/log/icinga/irc-wikidata.log'    => '#wikidata',
    '/var/log/icinga/irc-releng.log'      => '#wikimedia-releng',
    '/var/log/icinga/irc-cloud-feed.log'  => '#wikimedia-cloud-feed',
    '/var/log/icinga/irc-analytics.log'   => '#wikimedia-analytics',
    '/var/log/icinga/irc-ores.log'        => '#wikimedia-ai',
    '/var/log/icinga/irc-interactive.log' => '#wikimedia-interactive',
    '/var/log/icinga/irc-performance.log' => '#wikimedia-perf-bots',
    '/var/log/icinga/irc-fundraising.log' => '#wikimedia-fundraising',
    '/var/log/icinga/irc-reading-web.log' => '#wikimedia-reading-web-bots',
  }
  $ircecho_nick   = 'icinga-wm'
  $ircecho_server = 'chat.freenode.net +6697'

  ensure_packages('python-phabricator')

  if ($domain != 'test') {  # FIXME: There must be a better way to detect this.
    # TODO: need secrets module.  rename variable because 'proxypass' indicates a server proxy
    #include ::passwords::ldap::wmf_cluster
    #$ldap_bind_password = $passwords::ldap::wmf_cluster::proxypass
    $ldap_bind_password = 'placeholder'

    include nsca::firewall
    include monitoring::monitor::elasticsearch

    $ssl_settings = ssl_ciphersuite('apache', 'mid', true)

    ferm::service { 'icinga-https':
      proto => 'tcp',
      port  => 443,
    }

    ferm::service { 'icinga-http':
      proto => 'tcp',
      port  => 80,
    }

    httpd::site { $virtual_host:
      content => template("${module_name}/icinga/apache.erb"),
    }

    if os_version('debian >= stretch') {
      file { '/etc/apache2/conf-enabled/icinga.conf':
        ensure => absent,
      }
    }
    else {
      file { '/etc/apache2/conf.d/icinga.conf':
        ensure => absent,
      }
    }
    letsencrypt::cert::integrated { 'icinga':
      subjects   => $virtual_host,
      puppet_svc => 'apache2',
      system_svc => 'apache2',
    }

    # Phabricator Bot
    # TODO: secrets module
    #include ::passwords::phabricator
    $ops_monitoring_bot_token = 'placeholder'

    class { '::phabricator::bot':
      username => 'ops-monitoring-bot',
      token    => $ops_monitoring_bot_token,
      owner    => $icinga::icinga_user,
      group    => $icinga::icinga_group,
    }

    class { 'ircecho':
      ensure         => $ensure,
      ircecho_logs   => $ircecho_logs,
      ircecho_nick   => $ircecho_nick,
      ircecho_server => $ircecho_server,
    }

    # T28784 - IRC bots process need nagios monitoring
    # TODO: enable when nrpe is available
    # nrpe::monitor_service { 'ircecho':
    #   ensure       => $ensure,
    #   description  => 'ircecho_service_running',
    #   nrpe_command => '/usr/lib/nagios/plugins/check_procs -w 1:4 -c 1:20 -a ircecho',
    # }
  }
  else {
    # If in Vagrant, fall back to local auth.
    file { '/etc/icinga/htpasswd.users':
      content => 'admin:$6$A5e7/pKObWowY$PpcFrl5O9MZ4PfAAJFmIkOZTiFz7zoi.jdSqB4/8FxGEnvAe6I9rkooUcCpAGR/zyfBrXHzv29hc3OYSMPLwf1', # admin:admin
      mode    => '0644'
    }
  }
}
