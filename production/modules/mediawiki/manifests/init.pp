class mediawiki {
  $phpmysql = $osfamily ? {
    'redhat' => 'php-mysql',
    'debian' => 'php5-mysql',
    default  => 'php-mysql'
  }

  package { $phpmysql:
    ensure => 'present'
  }

  if $osfamily == 'redhat' {
    package { 'php-xml':
      ensure => 'present'
    }
  }

  class { '::apache':
    docroot    => '/var/www/html',
    mpm_module => 'prefork',
    subscribe  => Package[$phpmysql], # sets $phpmysql as a dependency
  }

  class { '::apache::mod::php': }
}
