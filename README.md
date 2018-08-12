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
