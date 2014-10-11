Magento Development Environment / Puppet provisioner for Vagrant
=============================

## Installation

Add this repository as submodule to your project as folder "puppet":

    git add submodule https://github.com/netzkollektiv/magento-vagrant-provisioner.git puppet

Add the following configuration for your vagrant file:

    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file  = "base.pp"
        puppet.module_path    = "puppet/modules"
    end

The provisioner expects the following project structure. Place the Magento database dump of your project in the projects root. The database will be imported automatically once you run the provisioner:

    /.modman
    /database.sql
    /modules
        /modman-module-1
        /modman-module-2
        /...
    /web
        /app
        /index.php
        /...


Run the provisioner:

    vagrant provision
