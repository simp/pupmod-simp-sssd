# This class sets up the [nss] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param reconnection_retries
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
#   If defined, this hash will be used to create the service
#   section instead of the parameters.  You must provide all options
#   in the section you want to add.  Each entry in the hash will be
#   added as a simple init pair key = value under the section in
#   the sssd.conf file.
#   No error checking will be performed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::nss (
  Optional[String]             $description                   = undef,
  Optional[Sssd::DebugLevel]   $debug_level                   = undef,
  Boolean                      $debug_timestamps              = true,
  Boolean                      $debug_microseconds            = false,
  Integer                      $reconnection_retries          = 3,
  Optional[Integer]            $fd_limit                      = undef,
  Optional[String]             $command                       = undef,
  Integer                      $enum_cache_timeout            = 120,
  Integer                      $entry_cache_nowait_percentage = 0,
  Integer                      $entry_negative_timeout        = 15,
  String                       $filter_users                  = 'root',
  String                       $filter_groups                 = 'root',
  Boolean                      $filter_users_in_groups        = true,
  Optional[String]             $override_homedir              = undef,
  Optional[String]             $fallback_homedir              = undef,
  Optional[String]             $override_shell                = undef,
  Optional[String]             $vetoed_shells                 = undef,
  Optional[String]             $default_shell                 = undef,
  Optional[Integer]            $get_domains_timeout           = undef,
  Optional[Integer]            $memcache_timeout              = undef,
  Optional[String]             $user_attributes               = undef,
  Optional[Hash]               $custom_options                = undef,
) {
  if $custom_options {
    $_content = epp(
      "${module_name}/service/custom_options.epp",
      {
        'service_name' => 'nss',
        'options'      => $custom_options,
      },
    )
  } else {
    $_content = epp(
      "${module_name}/service/nss.epp",
      {
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
    )
  }

  sssd::config::entry { 'puppet_service_nss':
    content => $_content,
  }
}
