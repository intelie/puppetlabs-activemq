# Class: intelie_activemq
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
#   class { 'intelie_activemq': }
# }
#
# To supply your own configuration file:
#
# node default {
#   class { 'intelie_activemq':
#     server_config => template('site/activemq.xml.erb'),
#   }
# }
#
class intelie_activemq(
  $version              = 'present',
  $ensure               = 'running',
  $packagename          = 'activemq',
  $user                 = 'activemq',
  $group                = 'activemq',
  $user_id              = undef, #defined by underlying class unless especified
  $group_id             = undef, #defined by underlying class unless especified
  $is_system            = undef, #defined by underlying class unless especified
  $password             = undef, #defined by underlying class unless especified
  $manage_home          = undef, #defined by underlying class unless especified
  $home_dir             = undef, #defined by underlying class unless especified
  $log_dir              = undef, #defined by underlying class unless especified
  $server_config        = undef, #defined by underlying class unless especified
  $server_config_path   = undef, #defined by underlying class unless especified
  $log4j_config         = undef, #defined by underlying class unless especified
  $log4j_config_path    = undef, #defined by underlying class unless especified
  $wrapper_config_path  = undef, #defined by underlying class unless especified
  $init_script_path     = undef, #defined by underlying class unless especified
  $java_initmemory      = undef, #defined by underlying class unless especified
  $java_maxmemory       = undef, #defined by underlying class unless especified
  $webconsole           = undef, #defined by underlying class unless especified
) {

  validate_re($ensure, '^running$|^stopped$')
  validate_re($version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$')

  $version_real     = $version
  $ensure_real      = $ensure
  $packagename_real = $packagename

  # Anchors for containing the implementation class
  anchor { 'begin':
    before => Class['packages'],
    notify => Class['service'],
  }

  class { 'packages':
    name               => $packagename_real,
    version            => $version_real,
    home               => $home_dir,
    user               => $user,
    group              => $group,
    user_id            => $user_id,
    group_id           => $group_id,
    is_system          => $is_system,
    password           => $password,
    manage_home        => $manage_home,
    init_script_path   => $init_script_path,
    notify             => Class['service'],
  }

  class { 'config':
    require             => Class['packages'],
    user                => $user,
    group               => $group,
    server_config       => $server_config,
    server_config_path  => $server_config_path,
    log4j_config        => $log4j_config,
    log4j_config_path   => $log4j_config_path,
    wrapper_config_path => $wrapper_config_path,
    home_dir            => $home_dir,
    log_dir             => $log_dir,
    java_initmemory     => $java_initmemory,
    java_maxmemory      => $java_maxmemory,
    webconsole          => $webconsole,
    notify              => Class['service'],
  }

  class { 'service':
    ensure => $ensure_real,
  }

  anchor { 'end':
    require => Class['service'],
  }

}
