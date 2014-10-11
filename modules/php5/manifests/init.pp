class php5 {
   # Install PHP5 and trigger Apache reload
   package { [ 'php5-xdebug', 'php5-cli', 'php5-common', 'php5-mysql', 'php5-curl', 'php5-gd', 'php5-intl', 'php5-mcrypt', 'libapache2-mod-php5' ]:
 	    ensure  => installed,
 	    require => [ Package['mysql-client'], Package['apache2'] ],
 	    notify  => Service['apache2'],
   }

   file { "/etc/php5/mods-available/xdebug-conf.ini":
       source  => '/vagrant/puppet/modules/php5/files/xdebug-conf.ini',
   }

   file { "/etc/php5/conf.d/22-xdebug-conf.ini":
       ensure  => 'link',
       target  => '/etc/php5/mods-available/xdebug-conf.ini',
       notify  => Service["apache2"],
   }
}
