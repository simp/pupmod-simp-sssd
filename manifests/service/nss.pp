# == Class: sssd::service::nss
#
# This class sets up the [nss] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
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
  Optional[String]             $user_attributes               = undef
) {
  include '::sssd'

  concat::fragment { 'sssd_nss.service':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/service/nss.erb")
  }
}
