node 'wiki' {
  file { '/info.txt':
    ensure  => 'present',
    content => inline_template("Created by Puppet at <%= Time.now %>\n")
  }

  package { 'ntp':
    ensure => 'installed'
  }
}

node 'wikitest' {
  package { 'ntp':
    ensure => 'installed'
  }
}
