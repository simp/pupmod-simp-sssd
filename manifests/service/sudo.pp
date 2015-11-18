# == Class: sssd::service::sudo
#
# This class sets up the [sudo] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::sudo (
  $description = '',
  $debug_level = '',
  $debug_timestamps = '',
  $sudo_timed = ''
) {

  validate_string($description)
  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
  unless empty($sudo_timed) { validate_bool($sudo_timed) }

  concat_fragment { 'sssd+sudo.service':
    content => template('sssd/service/sudo.erb')
  }
}
