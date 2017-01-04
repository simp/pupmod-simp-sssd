# == Class: sssd::service::pac
#
# This class sets up the [pac] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::pac (
  $description        = '',
  $debug_level        = '',
  $debug_timestamps   = '',
  $debug_microseconds = '',
  $allowed_uids = []
) {

#  validate_string($description)
#  validate_string($debug_level)
#  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
#  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
#  validate_array($allowed_uids)

  simpcat_fragment { 'sssd+pac.service':
    content => template('sssd/service/pac.erb')
  }
}
