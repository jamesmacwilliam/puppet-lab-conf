class linux {
  file { '/info.txt':
    ensure  => 'present',
    content => inline_template("Created by Puppet at <%= Time.now %>\n")
  }

  package { 'ntp':
    ensure => 'installed'
  }

  $ntpservice = $osfamily ? {
    'redhat' => 'ntpd',
    'debian' => 'ntp',
    default  => 'ntp'
  }

  service { $ntpservice:
    ensure  => 'running',
    enable  => true
  }
}

node 'wiki' {
  class { 'linux': }
}

node 'wikitest' {
  class { 'linux': }
}
