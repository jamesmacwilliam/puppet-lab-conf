node 'wiki' {
  #hiera_include('classes')
  class { 'linux': }
  class { 'mediawiki': }
}

node 'wikitest' {
  #hiera_include('classes')
  class { 'linux': }
  class { 'mediawiki': }
}
