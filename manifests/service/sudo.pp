# This class sets up the [sudo] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param sudo_timed
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::sudo (
  Optional[String]            $description        = undef,
  Optional[Sssd::Debuglevel]  $debug_level        = undef,
  Boolean                     $debug_timestamps   = true,
  Boolean                     $debug_microseconds = false,
  Boolean                     $sudo_timed         = false
) {
  include '::sssd'

  concat::fragment { 'sssd_sudo.service':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/service/sudo.erb"),
    order   => '30'
  }
}
