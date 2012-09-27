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
  $version        	    = 'present',
  $ensure          	    = 'running',
  $packagename	   	    = 'activemq',
  $home_dir,
  $log_dir,
  $server_config,
  $server_config_path,
  $log4j_config,
  $log4j_config_path,
  $wrapper_config_path,
  $init_script_path,
  $java_initmemory,
  $java_maxmemory,
  $webconsole,
) {

  validate_re($ensure, '^running$|^stopped$')
  validate_re($version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$')

  $version_real     = $version
  $ensure_real      = $ensure
  $packagename_real = $packagename

  # Anchors for containing the implementation class
  anchor { 'activemq::begin':
    before => Class['activemq::packages'],
    notify => Class['activemq::service'],
  }

  class { 'activemq::packages':
    name               => $packagename_real,
    version            => $version_real,
    home               => $home_dir,
    init_script_path   => $init_script_path,
    notify             => Class['activemq::service'],
  }

  class { 'activemq::config':
    require             => Class['activemq::packages'],
    server_config 	    => $server_config,
    server_config_path  => $server_config_path,
    log4j_config        => $log4j_config,
    log4j_config_path   => $log4j_config_path,
    wrapper_config_path => $wrapper_config_path,
    home_dir		        => $home_dir,
    log_dir             => $log_dir,
    java_initmemory     => $java_initmemory,
    java_maxmemory 	    => $java_maxmemory,
    webconsole          => $webconsole,
    notify              => Class['activemq::service'],
  }

  class { 'activemq::service':
    ensure => $ensure_real,
  }

  anchor { 'activemq::end':
    require => Class['activemq::service'],
  }

}
