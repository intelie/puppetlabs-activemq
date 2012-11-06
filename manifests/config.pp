# Class: intelie_activemq::config
#
#   class description goes here.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class intelie_activemq::config (
  $server_config       = 'UNSET',
  $server_config_path  = 'UNSET',
  $log4j_config        = 'UNSET',
  $log4j_config_path   = 'UNSET',
  $wrapper_config_path = 'UNSET',
  $home_dir 	   	     = '/usr/share/activemq',
  $log_dir 		   	     = '/var/log/activemq',
  $webconsole          = true, 
  $java_initmemory 	   = 512,
  $java_maxmemory      = 1024,
) {

  validate_bool($webconsole)
    
  $webconsole_real = $webconsole
  $home_dir_real   = $home_dir 
  $log_dir_real    = $log_dir
  
  $server_config_path_real = $server_config_path ? {
    'UNSET'  => "${home_dir_real}/conf/activemq.xml",
     default => $server_config_path
  }
   
  $log4j_config_path_real = $log4j_config_path ?{
    'UNSET'  => "${home_dir_real}/conf/log4j.properties",
    default  => $log4j_config_path
  }
  
  $wrapper_config_path_real = $wrapper_config_path ? {
  	'UNSET' => "${home_dir_real}/conf/activemq-wrapper.conf",
  	default => $wrapper_config_path
  }
  
  # Since these are templates, they should come _after_ all variables are set for
  # this class.
  $server_config_real = $server_config ? {
    'UNSET' => template("${module_name}/activemq.xml.erb"),
    default => $server_config,
  }
  
  $log4j_config_real = $log4j_config ? {
    'UNSET' => template("${module_name}/log4j.properties.erb"),
    default => $log4j_config,
  }  

  # Resource defaults
  File {
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0644',
    notify  => Service['activemq'],
    require => Package['activemq'],
  }

  # The configuration file itself.
  file { 'activemq.xml':
    ensure  => file,
    path    => $server_config_path_real,
    owner   => '0',
    group   => '0',
    content => $server_config_real,
  }
  
  file { 'log4j.properties':
    ensure  => file,
    path    => $log4j_config_path_real,
    owner   => '0',
    group   => '0',
    content => $log4j_config_real,
  }
  
  file { '/var/log/activemq':
    ensure  => directory,
    path	  => $log_dir_real,
    owner   => '0',
    group   => '0',
  }
  
  augeas { 'activemq-wrapper.conf':
    lens    => 'Properties.lns',
    incl    => "${wrapper_config_path_real}",
    context => "/files${wrapper_config_path_real}",
    changes => [
      "set wrapper.java.initmemory '${java_initmemory}'",
      "set wrapper.java.maxmemory '${java_maxmemory}'",
      "set set.default.ACTIVEMQ_HOME '${home_dir_real}'",
      "set set.default.ACTIVEMQ_BASE '${home_dir_real}'",
      "set wrapper.logfile '${log_dir_real}/wrapper.log'",
      "set wrapper.logfile.maxsize '50m'",
      "set wrapper.logfile.maxfiles '7'",
    ],
  }
  
  if ($home_dir_real == '/usr/share/activemq') {
    file {'/etc/activemq':
      target => $home_dir_real,
      ensure => link,
      force  => true,    
    }    
  }
 
}
