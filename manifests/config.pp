# Class: activemq::config
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
class activemq::config (
  $server_config,
  $home_dir 	   	 = '/usr/share/activemq',
  $log_dir 		   	 = '/var/log/activemq', 
  $java_initmemory 	 = 512,
  $java_maxmemory    = 1024,
  $wrapper_conf_path = 'UNSET',
) {

  validate_re($home_dir, '^/')
  $home_dir_real      = $home_dir
  $server_config_real = $server_config
  
  $xml_path = "${home_dir_real}/conf/activemq.xml"
  
  $wrapper_conf_path_real = $wrapper_conf_path ? {
  	'UNSET' => "${home_dir_real}/conf/activemq-wrapper.conf",
  	default => $wrapper_conf_path
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
    path    => $xml_path,
    owner   => '0',
    group   => '0',
    content => $server_config_real,
  }
  
  file { '/var/log/activemq':
    ensure  => directory,
    path	  => $log_dir,
    owner   => '0',
    group   => '0',
  }
  
  augeas { 'activemq-wrapper.conf':
    lens    => 'Properties.lns',
    incl    => "${wrapper_conf_path_real}",
    context => "/files/${wrapper_conf_path_real}",
    changes => [
      "set wrapper.java.initmemory '${java_initmemory}'",
      "set wrapper.java.maxmemory '${java_maxmemory}'",
      "set set.default.ACTIVEMQ_HOME '${home_dir_real}'",
      "set set.default.ACTIVEMQ_BASE '${home_dir_real}'",
      "set wrapper.logfile '${log_dir}/wrapper.log'",
      "set wrapper.logfile.maxsize '50m'",
      "set wrapper.logfile.maxfiles '7'",
    ],
  }

}
