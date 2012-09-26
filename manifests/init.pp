# Class: activemq
#
# This module manages the ActiveMQ messaging middleware.
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   Class['java']
#
# Sample Usage:
#
# node default {
#   class { 'activemq': }
# }
#
# To supply your own configuration file:
#
# node default {
#   class { 'activemq':
#     server_config => template('site/activemq.xml.erb'),
#   }
# }
#
class activemq(
  $version        	   = 'present',
  $ensure          	   = 'running',
  $webconsole     	   = true,
  $server_config  	   = 'UNSET',
  $packagename	   	   = 'activemq',
  $home_dir		         = "/usr/share/activemq",
  $java_initmemory,
  $java_maxmemory,
  $wrapper_conf_path,
  $custom_init_script,
) {

  validate_re($ensure, '^running$|^stopped$')
  validate_re($version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$')
  validate_bool($webconsole)

  $version_real     = $version
  $ensure_real      = $ensure
  $webconsole_real  = $webconsole
  $packagename_real = $packagename
  $home_dir_real	  = $home_dir

  # Since this is a template, it should come _after_ all variables are set for
  # this class.
  $server_config_real = $server_config ? {
    'UNSET' => template("${module_name}/activemq.xml.erb"),
    default => $server_config,
  }

  # Anchors for containing the implementation class
  anchor { 'activemq::begin':
    before => Class['activemq::packages'],
    notify => Class['activemq::service'],
  }

  class { 'activemq::packages':
  	name               => $packagename_real,
    version            => $version_real,
    home		           => $home_dir_real,
    custom_init_script => $custom_init_script,
    notify  	         => Class['activemq::service'],
  }

  class { 'activemq::config':
    server_config 	  => $server_config_real,
    require       	  => Class['activemq::packages'],
    notify        	  => Class['activemq::service'],
    home_dir		      => $home_dir,
    wrapper_conf_path => $wrapper_conf_path,
    java_initmemory   => $java_initmemory,
    java_maxmemory 	  => $java_maxmemory,
  }

  class { 'activemq::service':
    ensure => $ensure_real,
  }

  anchor { 'activemq::end':
    require => Class['activemq::service'],
  }

}

