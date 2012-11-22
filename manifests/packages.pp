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
  $user_id          = undef,
  $group_id         = undef,
  $is_system        = true,
  $password         = undef,
  $manage_home      = true,
  $init_script_path = 'UNSET',
) {

  validate_re($version, '^[._0-9a-zA-Z:-]+$')
  
  group {$group:
    ensure => present,
    gid    => $group_id,
    system => $is_system,
  } ->
  user {$user:
    ensure     => present,
    uid        => $user_id,
    gid        => $group_id,
    groups     => $group,
    system     => $is_system,
    password   => $password,
    home       => $home,
    managehome => $manage_home
  } ->
  package { 'activemq':
  	name	  => $name,
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
