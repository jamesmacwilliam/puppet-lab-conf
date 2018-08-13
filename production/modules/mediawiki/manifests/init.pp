class mediawiki {
  $wikidbserver = hiera('mediawiki::wikidbserver')
  $wikidbname = hiera('mediawiki::wikidbname')
  $wikidbuser = hiera('mediawiki::wikidbuser')
  $wikidbpassword = hiera('mediawiki::wikidbpassword')
  $wikiupgradekey = hiera('mediawiki::wikiupgradekey')
  $wikisitename = hiera('mediawiki::wikisitename')
  $wikimetanamespace = hiera('mediawiki::wikimetanamespace')
  $wikiserver = hiera('mediawiki::wikiserver')

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

  vcsrepo { '/var/www/html':
    ensure   => 'present',
    provider => 'git',
    source   => 'https://github.com/wikimedia/mediawiki.git',
    revision => 'REL1_23'
  }

  file { '/var/www/html/index.html':
    ensure => 'absent'
  }

  # resource ordering (remove index file before we clone from git
  File['/var/www/html/index.html'] -> Vcsrepo['/var/www/html']

  class { '::mysql::server':
    root_password => 'training' # obviously bad practice but this we're following a lab
  }

  class { '::firewall': }

  firewall { '000 allow http access':
    dport   => 80,
    proto   => 'tcp',
    action  => 'accept'
  }

  file { 'LocalSettings.php':
    path    => '/var/www/html/LocalSettings.php',
    ensure  => 'file',
    content => template('mediawiki/LocalSettings.php.erb')
  }
}
