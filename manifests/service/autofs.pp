# This class sets up the [autofs] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param autofs_negative_timeout
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::autofs (
  Optional[String]            $description              = undef,
  Optional[Sssd::DebugLevel]  $debug_level              = undef,
  Boolean                     $debug_timestamps         = true,
  Boolean                     $debug_microseconds       = false,
  Optional[Integer]           $autofs_negative_timeout  = undef,
) {
  include '::sssd'

  concat::fragment { 'sssd_autofs.service':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/service/autofs.erb"),
    order   => '30'
  }
}
