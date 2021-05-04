# This class sets up the [ifp] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) and sssd-ifp man pages.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param wildcard_limit
# @param allowed_uids
# @param user_attributes
#
# @param custom_options
#   If defined, this hash will be used to create the service
#   section instead of the parameters.  You must provide all options
#   in the section you want to add.  Each entry in the hash will be
#   added as a simple init pair
#    key = value
#   under the section in the sssd.conf file.
#   No error checking will be performed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::ifp (
  Optional[String]            $description        = undef,
  Optional[Sssd::Debuglevel]  $debug_level        = undef,
  Boolean                     $debug_timestamps   = true,
  Boolean                     $debug_microseconds = false,
  Optional[Integer[0]]        $wildcard_limit     = undef,
  Optional[Array[String[1]]]  $allowed_uids       = undef,
  Optional[Array[String[1]]]  $user_attributes    = undef,
  Optional[Hash]              $custom_options     = undef,
) {
  if $custom_options {
    $_content = epp("${module_name}/service/custom_options.epp", {
        'service_name' => 'ifp',
        'options'      => $custom_options
      })
  } else {
    $_content = template("${module_name}/service/ifp.erb")
  }

  sssd::config::entry { 'puppet_service_ifp':
    content => $_content
  }
}
