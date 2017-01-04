# == Class: sssd::service::autofs
#
# This class sets up the [autofs] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::autofs (
  Optional[String]  $description              = undef,
  Optional[String]  $debug_level              = undef,
  Boolean           $debug_timestamps         = true,
  Boolean           $debug_microseconds       = false,
  Optional[Integer] $autofs_negative_timeout  = undef,
) {
  simpcat_fragment { 'sssd+autofs.service':
    content => template('sssd/service/autofs.erb')
  }
}
