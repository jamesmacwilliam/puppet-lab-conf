class mediawiki {
  $phpmysql = $osfamily ? {
    'redhat' => 'php-mysql',
    'debian' => 'php5-mysql',
    default  => 'php-mysql'
  }

  package { $phpmysql:
    ensure => 'present'
  }
}
