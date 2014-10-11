class magento( $install, $db_user, $db_pass, $version, $admin_user, $admin_pass, $use_rewrites) {

    if $install {

        exec { "create-magentodb-db":
            unless  => "/usr/bin/mysql -uroot -p${mysql::root_pass} magentodb",
            command => "/usr/bin/mysqladmin -uroot -p${$mysql::root_pass} create magentodb",
            require => Service["mysql"],
        }

        exec { "grant-magentodb-db-all":
            unless  => "/usr/bin/mysql -u${db_user} -p${db_pass} magentodb",
            command => "/usr/bin/mysql -uroot -p${$mysql::root_pass} -e \"grant all on *.* to magento@'%' identified by '${db_pass}' WITH GRANT OPTION;\"",
            require => [ Service["mysql"], Exec["create-magentodb-db"] ],
        }

        exec { "grant-magentodb-db-localhost":
            unless  => "/usr/bin/mysql -u${db_user} -p${db_pass} magentodb",
            command => "/usr/bin/mysql -uroot -p${$mysql::root_pass} -e \"grant all on *.* to magento@'localhost' identified by '${db_pass}' WITH GRANT OPTION;\"",
            require => Exec["grant-magentodb-db-all"],
        }

        exec { "download-magento":
            cwd     => "/tmp",
            command => "/usr/bin/wget http://www.magentocommerce.com/downloads/assets/${version}/magento-${version}.tar.gz",
            creates => "/tmp/magento-${version}.tar.gz",
        }

        exec { "init-magento":
            cwd     => $apache2::document_root,
            command => "/bin/tar xvzf /tmp/magento-${version}.tar.gz; mv magento/* .; rm -r magento",
            timeout => 600,
            require => Exec["download-magento"],
        }

        exec { "setting-permissions":
            cwd     => "${apache2::document_root}",
            command => "/bin/chmod 550 mage; /bin/chmod o+w var var/.htaccess app/etc; /bin/chmod -R o+w media",
            require => Exec["init-magento"],
        }

        host { 'magento.localhost':
            ip      => '127.0.0.1',
        }

        exec { "import-magento-db":
            cwd     => "${apache2::document_root}",
            command => "cat ${apache2::document_root}/../database.sql | /usr/bin/mysql -u${db_user} -p${db_pass} magentodb",
            require => [ Exec["setting-permissions"], Exec["create-magentodb-db"], Package["php5-cli"] ],
        }

        file { "${apache2::document_root}/app/etc/local.xml":
            ensure  => file,
            content => template('magento/local.xml.erb'),
        }

        exec { "update-base-url":
            command => "echo \"UPDATE core_config_data SET value = 'http://magento.local:8123/' WHERE path in ('web/unsecure/base_url', 'web/secure/base_url');\" | /usr/bin/mysql -u${db_user} -p${db_pass} magentodb",
            require => [ Exec["import-magento-db"] ],
        }
    }

    file { "/etc/apache2/sites-available/magento":
        source  => '/vagrant/puppet/modules/magento/files/vhost_magento',
        require => Package["apache2"],
        notify  => Service["apache2"],
    }

    file { "/etc/apache2/sites-enabled/magento":
        ensure  => 'link',
        target  => '/etc/apache2/sites-available/magento',
        require => Package["apache2"],
        notify  => Service["apache2"],
    }

    exec { "sudo a2enmod rewrite":
        require => Package["apache2"],
        notify  => Service["apache2"],
    }
}
