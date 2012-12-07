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
  $home             = undef,
) {

  validate_re($version, '^[._0-9a-zA-Z:-]+$')
    
  package { 'activemq':
    name    => $name,
    ensure  => $version,
    notify  => Service['activemq'],
  }

}
