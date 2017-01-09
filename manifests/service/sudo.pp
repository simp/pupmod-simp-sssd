# == Class: sssd::service::sudo
#
# This class sets up the [sudo] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::sudo (
  Optional[String]  $description        = undef,
  Optional[String]  $debug_level        = undef,
  Boolean           $debug_timestamps   = true,
  Boolean           $debug_microseconds = false,
  Boolean           $sudo_timed         = false
) {

  simpcat_fragment { 'sssd+sudo.service':
    content => template('sssd/service/sudo.erb')
  }
}
