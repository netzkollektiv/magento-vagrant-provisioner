class modman {
    exec { 'wget -O /usr/bin/modman https://raw.github.com/colinmollenhour/modman/master/modman':
        creates => "/usr/bin/modman",
        require => Package['wget'],
    }
    file  {'/usr/bin/modman':
        owner   =>  'root',
        group   =>  'root',
        ensure  =>  file,
        mode    => '0755',
    }
}
