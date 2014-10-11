# install n98-magerun
class n98-magerun {
    exec { 'wget -O /usr/bin/n98-magerun.phar https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar':
        creates => "/usr/bin/n98-magerun.phar",
        require => Package['wget'],
    }
    file  {'/usr/bin/n98-magerun.phar':
        owner   =>  'root',
        group   =>  'root',
        ensure  =>  file,
        mode    => '0755',
    }
}
