# Class: intelie_activemq::service
#
#   Manage the ActiveMQ Service
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class intelie_activemq::service(
  $ensure,
  $user,
  $group,
  $home_dir,
) {

  # Arrays cannot take anonymous arrays in Puppet 2.6.8
  $v_ensure = [ '^running$', '^stopped$' ]
  validate_re($ensure, $v_ensure)

  $ensure_real = $ensure

  file {$home_dir:
    ensure  => present,
    owner   => $user,
    group   => $group,
    notity  => Service['activemq'],
  }

  service { 'activemq':
    ensure     => $ensure_real,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['packages'],
  }

}
