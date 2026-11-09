# This class sets up the [ssh] section of /etc/sssd/sssd.conf.
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
# @param ssh_hash_known_hosts
#   Removed from SSSD's schema in 2.10 along with the sssd-managed
#   ``known_hosts`` workflow it controlled, which ``sss_ssh_knownhosts`` and
#   OpenSSH's ``KnownHostsCommand`` now replace.  The `simp:defaults` profile
#   sets it on the releases that still accept it.
#
# @param ssh_known_hosts_timeout
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
class sssd::service::ssh (
  Optional[String]                                    $description             = undef,
  Optional[Variant[Sssd::DebugLevel, Enum['absent']]] $debug_level             = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_timestamps        = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_microseconds      = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $ssh_hash_known_hosts    = undef,
  Optional[Variant[Integer, Enum['absent']]]          $ssh_known_hosts_timeout = undef,
  Optional[Hash]                                      $custom_options          = undef,
) {
  $_settings = $custom_options ? {
    undef   => {
      'description'             => $description,
      'debug_level'             => $debug_level,
      'debug_timestamps'        => $debug_timestamps,
      'debug_microseconds'      => $debug_microseconds,
      'ssh_hash_known_hosts'    => $ssh_hash_known_hosts,
      'ssh_known_hosts_timeout' => $ssh_known_hosts_timeout,
    },
    default => $custom_options,
  }

  sssd::config::entry { 'puppet_service_ssh':
    section  => 'ssh',
    settings => $_settings,
  }
}
