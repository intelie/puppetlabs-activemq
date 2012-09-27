# Class: activemq::packages
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
class activemq::packages (
  $name,
  $version,
  $home 		        = '/usr/share/activemq',
  $init_script_path = 'UNSET',
) {

  validate_re($version, '^[._0-9a-zA-Z:-]+$')

  $version_real = $version
  $home_real    = $home
  $name_real	  = $name

  # Manage the user and group in Puppet rather than RPM
  group { 'activemq':
    ensure => 'present',
    gid    => '92',
    before => User['activemq']
  }
  user { 'activemq':
    ensure  => 'present',
    comment => 'Apache Activemq',
    gid     => '92',
    home    => $home_real,
    shell   => '/bin/bash',
    uid     => '92',
    before  => Package['activemq'],
  }
  file { $home_real:
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0755',
    before => Package['activemq'],
  }

  package { 'activemq':
  	name	=> $name_real,
    ensure  => $version_real,
    notify  => Service['activemq'],
  }

  if $init_script_path == 'UNSET' {
	  file { '/etc/init.d/activemq':
	    ensure  => file,
	    path    => '/etc/init.d/activemq',
	    content => template("${module_name}/init/activemq"),
	    owner   => '0',
	    group   => '0',
	    mode    => '0755',
	  }
  } else {
	  file {'/etc/init.d/activemq':
	    target => $init_script_path,
	    ensure => link,    
	  } 
  }

}
