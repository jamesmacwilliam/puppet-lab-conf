class linux {
  $ntpservice = $osfamily ? {
    'redhat' => 'ntpd',
    'debian' => 'ntp',
    default  => 'ntp'
  }

  $admintools = ['git', 'nano', 'screen']

  package { $admintools:
    ensure => 'installed'
  }

  package { 'ntp':
    ensure => 'installed'
  }

  service { $ntpservice:
    ensure  => 'running',
    enable  => true
  }

  file { '/info.txt':
    ensure  => 'present',
    content => inline_template("Created by Puppet at <%= Time.now %>\n")
  }
}

$wikidbserver = 'localhost'
$wikidbname = 'wiki'
$wikidbuser = 'root'
$wikidbpassword = 'training'
$wikiupgradekey = 'puppet'

node 'wiki' {
  $wikisitename = 'wiki'
  $wikimetanamespace = 'Wiki'
  $wikiserver = 'http://172.31.0.202'

  class { 'linux': }
  class { 'mediawiki': }
}

node 'wikitest' {
  $wikisitename = 'wikitest'
  $wikimetanamespace = 'WikiTest'
  $wikiserver = 'http://172.31.0.203'

  class { 'linux': }
  class { 'mediawiki': }
}
