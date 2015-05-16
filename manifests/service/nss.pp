# == Class: sssd::service::nss
#
# This class sets up the [nss] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# == Parameters
#
# [*description*]
# [*debug_level*]
# [*debug_timestamps*]
# [*reconnection_retries*]
# [*command*]
# [*enum_cache_timeout*]
# [*entry_cache_nowait_percentage*]
# [*entry_negative_timeout*]
# [*filter_users*]
# [*filter_groups*]
# [*filter_users_in_groups*]
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::nss (
  $description = '',
  $debug_level = '',
  $debug_timestamps = '',
  $reconnection_retries = '3',
  $command = '',
  $enum_cache_timeout = '120',
  $entry_cache_nowait_percentage = '0',
  $entry_negative_timeout = '15',
  $filter_users = 'root',
  $filter_groups = 'root',
  $filter_users_in_groups = ''
) {

  concat_fragment { 'sssd+nss.service':
    content => template('sssd/service/nss.erb')
  }

  validate_integer($reconnection_retries)
  validate_integer($enum_cache_timeout)
  validate_integer($entry_cache_nowait_percentage)
  validate_integer($entry_negative_timeout)
}
