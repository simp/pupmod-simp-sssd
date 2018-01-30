# This class sets up the [ssh] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param ssh_hash_known_hosts
# @param ssh_known_hosts_timeout
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
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
