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
}
