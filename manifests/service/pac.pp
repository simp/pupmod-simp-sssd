# This class sets up the [pac] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param allowed_uids
#
# @param custom_options
#   If defined, this hash will be used to create the service
#   section instead of the parameters.  You must provide all options
#   in the section you want to add.  Each entry in the hash will be
#   added as a simple init pair key = value under the section in
#   the sssd.conf file.
#   No error checking will be performed.
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::pac (
  Optional[String]             $description        = undef,
  Optional[Sssd::DebugLevel]   $debug_level        = undef,
  Boolean                      $debug_timestamps   = true,
  Boolean                      $debug_microseconds = false,
  Array[String]                $allowed_uids       = [],
  Optional[Hash]               $custom_options     = undef,
) {
  if $custom_options {
    $_content = epp(
      "${module_name}/service/custom_options.epp",
      {
        'service_name' => 'pac',
        'options'      => $custom_options,
      },
    )
  } else {
    $_content = epp(
      "${module_name}/service/pac.epp",
      {
        'description'        => $description,
        'debug_level'        => $debug_level,
        'debug_timestamps'   => $debug_timestamps,
        'debug_microseconds' => $debug_microseconds,
        'allowed_uids'       => $allowed_uids,
        'custom_options'     => $custom_options,
      },
    )
  }

  sssd::config::entry { 'puppet_service_pac':
    content => $_content,
  }
}
