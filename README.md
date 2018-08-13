 ## Puppet environment files

  ## Modules

- to generate a new module download puppet development kit: `brew cask install puppetlabs/puppet/pdk`
    https://puppet.com/docs/pdk/1.x/pdk.html

* may need to add `eval $(/usr/libexec/path_helper -s)` if using zshell

- then run `pdk new module <module-name>`


 #### Add existing modules
https://forge.puppet.com

- `puppet module install <module> --version <version> --modulepath production/modules` #modulepath/version are optional
* must have puppet installed

 ## Notes
- resources: (Big 3 are Package/File/Service)
  https://puppet.com/docs/puppet/5.5/type.html (all core resources)
  https://puppet.com/docs/puppet/5.5/cheatsheet_core_types.html (most used resources)

  * can also get resource def via `puppet describe <resource>`
- run puppet on individual files: `puppet apply <some init file>` (useful for one-off provisioning like a puppetserver)

- set defaults for a resource via capitalized reference:
  ```
  File {
    owner => 'root'
  }
  ```
  now `file { 'some file' }` will have a default owner of root

- interpolation `notify { "The ${ntp_service} is up and runnig": }`
- Heredoc
  ```
  $ntp_conf = @(END)
  driftfile /var/lib/ntp/drift
  server tock prefer iburst
  server uk.pool.ntp.org
  END
  ```
  - variable naming rules - must be all lowercase and can contain _

 ## Facts

 - can access all facts by running `facter` (or `facter <some key>`)
 - accessible in code via `$facts['os']['family']` # Note: accessing via $osfamily or $::osfamily is deprecated since it can be overwritten

 ## Conditionals
 ```
 # note: the string comparison is not case sensitive, could just as easily do == 'redhat'
 if $facts['os']['family'] == 'Redhat' {
   notify { 'Red Hat': }
 }
 elsif $facts['os']['family'] == 'debian' {
   notify { 'Debian': }
 }
 else {
   # notice facts has no dollar sign when interpolated
   fail("Unsupported OS ${facts['os']['family']}")
 }
 #  unless... works similarly

 case $facts['os']['family'] {
   'Redhat': { notify { 'Red Hat': } }
   default: { fail("Unsupported OS ${facts['os']['family']}") }
 }

 # selector:
 $ntp_service = $facts['os']['family'] ? {
   'Redhat' => 'ntpd',
   'Debian' => 'ntp'
 }
 ```

 ## Regular Expressions
`$facts['os']['family'] =~ /Redhat/ #compatible with rubular.com syntax`

 ## Iteration with lambdas
```
each ( $facts['partitions'] ) | $devname, $devprops | {
  # do some stuff
}
```
 ## ordering
- since puppet 4, we order things in the order they show up in a manifest
- meta parameters example:
  `package { 'pkg1': before => File['file1'] }`
  * we can similarly use `require => Service['some service']` # run after a thing
  * Autorequires: some resources auto require things to happen before they run (ie: user with group auto requires the group first) `puppet describe user | grep -A5 Autorequires` shows us these for a resource
  * the `before/require` keywords can trigger restarting things like services if a dependent file is changed, we can do this with the `notify` keyword
  ```
  # pkg1 must be done before the file creation, but when the file changes service1 restarts
  package { 'pkg1': before => File['file1'] }
  file { 'file1': notify => Service['service1'] }
  service { 'service1': subscribe => File['file1'] }
  ```

  * can also use the `Package['ntp'] -> File['file1'] ~> Service['service1']`
  for the same thing, however, this shortened format is not recommended by the styleguide since it is not as readable

   ## modules
   - `puppet config print environment` (current environment)
   - `puppet module list`
   - `puppet module install puppetlabs/ntp --version <somever> --modulepath production/modules` install from puppet forge
   - `pdk new module <module name>` new custom module
   * module strcture: manifests, files (static files), lib (custom facts), facts.d (external facts Ruby facts), templates
     - things within files can be accessed via the `file` method `content => file(<module>/<file>)`

 ## classes
   - can `include` classes within another class
   - can accept variables via: `class foo ( String $some_var = 'Default Val' ) { # do some stuff }`
       * type `String` is optional if we want to enforce the variable type
       * to use a class and pass variable: `class { 'foo': some_var => 'My Val' }`
       * use the Abstract data types (ie: `Variant` to do more complex DataType enforcement: https://puppet.com/docs/puppet/4.9/lang_data_type.html
   - inheritance:
     ```
     class ntp::config(
       $location = 'london'
     ) inherits ntp::params {
       # do stuff
     }
     ```
## Types
 - define custom type within a module at: lib/puppet/type/myfile.rb
 note: the `namevar` option for our custom param means it is that first argument.
 ```
 Puppet::Type.newtype(:myfile) do
   desc 'My File Type'
   ensurable
   newparam(:path, :namevar => true) do
     desc 'The path to the file'
   end
 end
 ``` 

 the Type tells what we want to do, but now we need a Provider to actually do the work:
 ```
 # lib/puppet/provider/myfile/posix.rb
 Puppet::Type(:myfile).provide(:posix) do
   desc 'Simple File Support'

   def exists?
     File.exists?(@resource[:name])
   end

   def create
     File.open(@resource[:name], 'w') { |f| f.puts '' }
   end

   def destroy
     File.unlink(@resource[:name])
   end
 end
 ```
 - we can now run `puppet describe myfile` to see our new resource
  * use it via: `myfile { '/etc/puppet/puppet.conf', ensure => 'present' }`
    `present` will check existence via the `exists?` method and then create or destroy based on `ensure => '<present/absent>'`

 ## Defined Types
  - think of these as functions in ruby, just there to encapsulate repetitive simple logic
  - these are defined within a .pp file rather than a ruby file, so they are typically wrappers around existing types (much simpler than the ruby types)
  ```
  define ntp::admin_file {
    include ntp::params
    $admingroup = $ntp::params:admingroup
    file { $title :
      content => file('ntp/ntp.conf')
    }
  }
  ```

 ## Templates
 - ERB
   * inline_template or via .erb in the templates dir `$` vars change to `@` vars within the template ie: `<%= @facts['os']['family'] %>`
   * `file { 'foo': content => template('/some_module/file.conf.erb') }`
 - EPP templates (embedded puppet) puppet >= 4 example: `<%= $facts['os']['family'] %>` (notice the variables use the `$` sign within the EPP, use this via `inline_epp(<some name>, { 'foo' => 'bar' })`
    also via:
   * `file { 'foo': content => epp('/some_module/file.conf.epp') }`
   * conditionals: notice how we replace do/end
   ```
   <% unless $monitor == true { -%>
     disable monitor
   <% } -%>
   ```
   * testing:
    - validate via `puppet epp validate <epp file>`
    - render via: `puppet epp render <epp file> --values '{ m => 3 }'`

 ## Delivering Files
 - purging:
  `resources { 'host': purge => true }` also accepts a `noop => true` parameter that we can use to stop it from running in some circumstances
  * this will clear any hosts that are not managed by puppet on our system (/etc/hosts), this is a special resource type that allows us to do overarching actions on a type
`file { 'somefile': recurse => true, ensure => 'some/directory', purge => true }` - recursively manage files in the directory and purge non-managed files

 ## Using file_line (a bit like grep)
- part of `puppetlabs/stdlib` (at puppet forge)
- this is a great way to add a single line to a file such as a hosts file
ie:
```
file_line { '/etc/hosts':
  line => '<some ip> puppetmaster'
}

# or
# if we want to manage more than 1 line in the same file

file_line { 'puppetmaster':
  path   => '/etc/hosts',
  line   => '<some ip> puppetmaster'
  match  => '.*puppetmaster.*' # can use regex to determine if line already exists
  ensure => 'absent|present' # default is present
}
```

 ## Delivery of file parts with concat
 - 'puppetlabs/concat' at puppet forge
    ```
    concat { '/etc/puppet/puppet.conf':
      ensure         => present,
      ensure_newline => true, # new line at the end of each of our fragments
    }
    concat::fragment { 'main':
      target  => '/etc/puppet/puppet.conf',
      content => 'content for the main block here, also can pull in a file fragment',
      order   => '01'
    }
    # can also use `source => 'http/file://' to fetch the file fragment
    ```

 ## Hiera
- when interpolating in our hiera.yaml file we can reference facter using the following:
    * Notice instead of `$facts['os']['family']` hiera allows for `facts.os.family` within interpolation, if any node does not exist, it returns an empty string
hierarchy is: global /etc/puppetlabs/puppet/hiera.yaml then environment, then modules with modules holding the highest precidence (can override globals/env in module hiera)
```
version: 5
hierarchy:
  - name: 'Hostnames'
  - path: "${facts.os.family}"
defaults:
  data_hash: yaml_data
  datadir: data
```

 ## Puppet Server
- min 4gb ram
- node definitions (can use node default as a catch all)
