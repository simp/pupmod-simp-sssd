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
  $description = '',
  $debug_level = '',
  $debug_timestamps = '',
  $debug_microseconds = '',
  $reconnection_retries = '3',
  $fd_limit = '',
  $command = '',
  $enum_cache_timeout = '120',
  $entry_cache_nowait_percentage = '0',
  $entry_negative_timeout = '15',
  $filter_users = 'root',
  $filter_groups = 'root',
  $filter_users_in_groups = '',
  $override_homedir = '',
  $fallback_homedir = '',
  $override_shell = '',
  $vetoed_shells = '',
  $default_shell = '',
  $get_domains_timeout = '',
  $memcache_timeout = '',
  $user_attributes = ''
) {

#  validate_string($description)
#  validate_string($debug_level)
#  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
#  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
#  validate_integer($enum_cache_timeout)
#  validate_integer($entry_cache_nowait_percentage)
#  validate_integer($entry_negative_timeout)
#  validate_string($override_homedir)
#  validate_string($fallback_homedir)
#  validate_string($override_shell)
#  validate_string($vetoed_shells)
#  validate_string($default_shell)
#  unless empty($get_domains_timeout) { validate_integer($get_domains_timeout) }
#  unless empty($memcache_timeout) { validate_integer($memcache_timeout) }
#  validate_string($user_attributes)

  simpcat_fragment { 'sssd+nss.service':
    content => template('sssd/service/nss.erb')
  }

  validate_integer($reconnection_retries)
}
