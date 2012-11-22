# Class: intelie_activemq::packages
#
#   ActiveMQ Packages
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class intelie_activemq::packages (
  $name             = undef,
  $version          = present,
  $home             = '/usr/share/activemq',
  $user             = 'activemq',
  $group            = 'activemq',
  $init_script_path = 'UNSET',
) {

  validate_re($version, '^[._0-9a-zA-Z:-]+$')
    
  file { $home:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
    before => Package['activemq'],    
  }
  
  package { 'activemq':
    name    => $name,
    ensure  => $version,
    notify  => Service['activemq'],
  }

  if $init_script_path == 'UNSET' {
	  file { '/etc/init.d/activemq':
	    ensure  => file,
	    path    => '/etc/init.d/activemq',
	    content => template("${module_name}/init/activemq"),
	    owner   => $user,
	    group   => $group,
	    mode    => '0755',
	  }
  } else {
	  file {'/etc/init.d/activemq':
	    target => $init_script_path,
	    ensure => link,    
	  } 
  }

}
