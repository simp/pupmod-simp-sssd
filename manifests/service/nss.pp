# This class sets up the [nss] section of /etc/sssd/sssd.conf.
# You may only have one of these per system.
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
# @param reconnection_retries
#   Removed from SSSD's schema in 2.10, with no successor.  The
#   `simp:defaults` profile sets it on the releases that still accept it.
#
# @param fd_limit
# @param command
# @param enum_cache_timeout
# @param entry_cache_nowait_percentage
# @param entry_negative_timeout
# @param filter_users
# @param filter_groups
# @param filter_users_in_groups
# @param override_homedir
# @param fallback_homedir
# @param override_shell
# @param vetoed_shells
# @param default_shell
# @param get_domains_timeout
# @param memcache_timeout
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
class sssd::service::nss (
  Optional[String]                                    $description                   = undef,
  Optional[Variant[Sssd::DebugLevel, Enum['absent']]] $debug_level                   = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_timestamps              = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_microseconds            = undef,
  Optional[Variant[Integer, Enum['absent']]]          $reconnection_retries          = undef,
  Optional[Variant[Integer, Enum['absent']]]          $fd_limit                      = undef,
  Optional[String]                                    $command                       = undef,
  Optional[Variant[Integer, Enum['absent']]]          $enum_cache_timeout            = undef,
  Optional[Variant[Integer, Enum['absent']]]          $entry_cache_nowait_percentage = undef,
  Optional[Variant[Integer, Enum['absent']]]          $entry_negative_timeout        = undef,
  Optional[String]                                    $filter_users                  = undef,
  Optional[String]                                    $filter_groups                 = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $filter_users_in_groups        = undef,
  Optional[String]                                    $override_homedir              = undef,
  Optional[String]                                    $fallback_homedir              = undef,
  Optional[String]                                    $override_shell                = undef,
  Optional[String]                                    $vetoed_shells                 = undef,
  Optional[String]                                    $default_shell                 = undef,
  Optional[Variant[Integer, Enum['absent']]]          $get_domains_timeout           = undef,
  Optional[Variant[Integer, Enum['absent']]]          $memcache_timeout              = undef,
  Optional[String]                                    $user_attributes               = undef,
  Optional[Hash]                                      $custom_options                = undef,
) {
  $_settings = $custom_options ? {
    undef   => {
      'description'                   => $description,
      'debug_level'                   => $debug_level,
      'debug_timestamps'              => $debug_timestamps,
      'debug_microseconds'            => $debug_microseconds,
      'reconnection_retries'          => $reconnection_retries,
      'fd_limit'                      => $fd_limit,
      'command'                       => $command,
      'enum_cache_timeout'            => $enum_cache_timeout,
      'entry_cache_nowait_percentage' => $entry_cache_nowait_percentage,
      'entry_negative_timeout'        => $entry_negative_timeout,
      'filter_users'                  => $filter_users,
      'filter_groups'                 => $filter_groups,
      'filter_users_in_groups'        => $filter_users_in_groups,
      'override_homedir'              => $override_homedir,
      'fallback_homedir'              => $fallback_homedir,
      'override_shell'                => $override_shell,
      'vetoed_shells'                 => $vetoed_shells,
      'default_shell'                 => $default_shell,
      'get_domains_timeout'           => $get_domains_timeout,
      'memcache_timeout'              => $memcache_timeout,
      'user_attributes'               => $user_attributes,
    },
    default => $custom_options,
  }

  sssd::config::entry { 'puppet_service_nss':
    section  => 'nss',
    settings => $_settings,
  }
}
