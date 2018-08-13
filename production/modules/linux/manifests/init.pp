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
    content => inline_template("Hello World\nCreated by Puppet at <%= Time.now %>\n")
  }
}
