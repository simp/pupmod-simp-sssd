# == Class: sssd::service::ssh
#
# This class sets up the [ssh] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::ssh (
  Optional[String]             $description             = undef,
  Optional[Sssd::DebugLevel]   $debug_level             = undef,
  Boolean                      $debug_timestamps        = true,
  Boolean                      $debug_microseconds      = false,
  Boolean                      $ssh_hash_known_hosts    = true,
  Optional[Integer]            $ssh_known_hosts_timeout = undef
) {
  include '::sssd'

  concat::fragment { 'sssd_ssh.service':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/service/ssh.erb")
  }
}
