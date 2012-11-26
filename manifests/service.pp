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
  $home,
) {

  # Arrays cannot take anonymous arrays in Puppet 2.6.8
  $v_ensure = [ '^running$', '^stopped$' ]
  validate_re($ensure, $v_ensure)

  $ensure_real = $ensure

  file {$home:
    ensure  => present,
    owner   => $user,
    group   => $group,
    notify  => Service['activemq'],
  }

  service { 'activemq':
    ensure     => $ensure_real,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['packages'],
  }

}
