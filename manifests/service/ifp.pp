# This class sets up the [ifp] section of /etc/sssd/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) and sssd-ifp man pages.
#
# Each parameter that maps to a setting follows three states: `undef` (the
# default) leaves the setting alone, a value sets it, and `'absent'` removes
# it.  The class manages nothing until one of them is set.
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
#   If defined, these settings are managed in the section *instead of* the
#   ones from the other parameters, which are then ignored.  Each entry is
#   edited in place as `key = value` in the generated `/etc/sssd/conf.d/`
#   drop-in file; a value of `'absent'` removes that setting.
#   No error checking will be performed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::ifp (
  Optional[String]                                    $description        = undef,
  Optional[Variant[Sssd::DebugLevel, Enum['absent']]] $debug_level        = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_timestamps   = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_microseconds = undef,
  Optional[Variant[Integer[0], Enum['absent']]]       $wildcard_limit     = undef,
  Optional[Variant[Array[String[1]], Enum['absent']]] $allowed_uids       = undef,
  Optional[Variant[Array[String[1]], Enum['absent']]] $user_attributes    = undef,
  Optional[Hash]                                      $custom_options     = undef,
) {
  $_settings = $custom_options ? {
    undef   => {
      'description'        => $description,
      'debug_level'        => $debug_level,
      'debug_timestamps'   => $debug_timestamps,
      'debug_microseconds' => $debug_microseconds,
      'allowed_uids'       => $allowed_uids,
      'user_attributes'    => $user_attributes,
      'wildcard_limit'     => $wildcard_limit,
    },
    default => $custom_options,
  }

  sssd::config::entry { 'puppet_service_ifp':
    section  => 'ifp',
    settings => $_settings,
  }
}
