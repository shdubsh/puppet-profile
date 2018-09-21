class profile::puppetmaster {
  class { 'puppetserver':
    config => {
      'java_args'     => {
        'xms'         => '512m',
        'xmx'         => '1g',
        'maxpermsize' => '512m',
        'tmpdir'      => '/tmp',
      }
    }
  }

  ensure_packages([
    'python-jinja2',
    'python-mysqldb',
    'python-sqlalchemy',
    'python-requests'
  ])

  file {'/usr/local/bin/naggen2':
    ensure  => 'present',
    mode    => '0555',
    source  => "puppet:///modules/${module_name}/puppetmaster/naggen2",
  }
}
