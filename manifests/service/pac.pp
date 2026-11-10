# This class sets up the [pac] section of /etc/sssd/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# Each parameter that maps to a setting follows three states: `undef` (the
# default) leaves the setting alone, a value sets it, and `'absent'` removes
# it.  The class manages nothing until one of them is set.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param allowed_uids
#   An empty Array is treated as `undef`.
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
class sssd::service::pac (
  Optional[String]                                    $description        = undef,
  Optional[Variant[Sssd::DebugLevel, Enum['absent']]] $debug_level        = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_timestamps   = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_microseconds = undef,
  Optional[Variant[Array[String], Enum['absent']]]    $allowed_uids       = undef,
  Optional[Hash]                                      $custom_options     = undef,
) {
  $_settings = $custom_options ? {
    undef   => {
      'description'        => $description,
      'debug_level'        => $debug_level,
      'debug_timestamps'   => $debug_timestamps,
      'debug_microseconds' => $debug_microseconds,
      'allowed_uids'       => $allowed_uids ? { Array[String, 1] => $allowed_uids.join(','), Array => undef, default => $allowed_uids },
    },
    default => $custom_options,
  }

  sssd::config::entry { 'puppet_service_pac':
    section  => 'pac',
    settings => $_settings,
  }
}
