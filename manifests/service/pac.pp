# == Class: sssd::service::pac
#
# This class sets up the [pac] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::pac (
  Optional[String]   $description        = undef,
  Optional[String]   $debug_level        = undef,
  Boolean            $debug_timestamps   = true,
  Boolean            $debug_microseconds = false,
  Array[String]      $allowed_uids       = []
) {
  simpcat_fragment { 'sssd+pac.service':
    content => template('sssd/service/pac.erb')
  }
}
