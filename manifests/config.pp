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
  $init_script           = 'UNSET',  
  $server_config         = 'UNSET',
  $server_config_path    = 'UNSET',
  $log4j_config          = 'UNSET',
  $log4j_config_path     = 'UNSET',
  $wrapper_config_path   = 'UNSET',
  $wrapper_conf_template = undef,
  $home_dir              = '/usr/share/activemq',
  $log_dir               = '/var/log/activemq',
  $webconsole            = true, 
  $java_initmemory       = 512,
  $java_maxmemory        = 1024,
  $user                  = 'activemq',
  $group                 = 'activemq',
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
  $init_script_real = $init_script ? {
    'UNSET' => template("${module_name}/init/activemq.erb"),
    default => $init_script,
  }  
  
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
    owner   => $user,
    group   => $group,
    notify  => Service['activemq'],
    require => Package['activemq'],
  }

  file { '/etc/init.d/activemq':
    ensure  => file,
    content => $init_script_real,
    mode    => '0755',
  } 

  file { 'activemq.xml':
    ensure  => file,
    path    => $server_config_path_real,
    content => $server_config_real,
    mode    => '0644',
  } 
  
  file { 'log4j.properties':
    ensure  => file,
    path    => $log4j_config_path_real,
    content => $log4j_config_real,
    mode    => '0644',    
  } 
  
  if $wrapper_conf_template != undef {
    file {'activemq-wrapper.conf':
      ensure  => file,
      path    => $wrapper_config_path_real,
      mode    => 0644,
      content => $wrapper_conf_template,
    }  
  } else {
    augeas {'activemq-wrapper.conf':
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
    } ->
    file {$wrapper_config_path_real:
      ensure  => present,
      mode    => '0644',    
    }  
  } 
 
  
  file {$home_dir_real:
    ensure  => present,
    recurse => true,
    links   => follow,
    ignore  => 'libexec', 
  }
  
  file {$log_dir_real:
    ensure  => present,
    recurse => true,
  }
  
  file {'/var/run/activemq':
    ensure  => directory,
    recurse => true,
  }
  
}
