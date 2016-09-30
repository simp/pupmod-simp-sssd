# == Class: sssd::service::autofs
#
# This class sets up the [autofs] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::autofs (
  $description             = '',
  $debug_level             = '',
  $debug_timestamps        = '',
  $debug_microseconds      = '',
  $autofs_negative_timeout = ''
) {

  validate_string($description)
  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
  unless empty($autofs_negative_timeout) { validate_integer($autofs_negative_timeout) }

  simpcat_fragment { 'sssd+autofs.service':
    content => template('sssd/service/autofs.erb')
  }
}
