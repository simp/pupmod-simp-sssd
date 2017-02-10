# == Class: sssd::service::pac
#
# This class sets up the [pac] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::pac (
  Optional[String]             $description        = undef,
  Optional[Sssd::DebugLevel]   $debug_level        = undef,
  Boolean                      $debug_timestamps   = true,
  Boolean                      $debug_microseconds = false,
  Array[String]                $allowed_uids       = []
) {
  include '::sssd'

  concat::fragment { 'sssd_pac.service':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/service/pac.erb")
  }
}
