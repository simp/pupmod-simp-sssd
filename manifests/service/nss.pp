# == Class: sssd::service::nss
#
# This class sets up the [nss] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
# === Parameters Available in this Template:
# command
# description
# debug_level
# debug_timestamps
# debug_microseconds
# default_shell
# entry_cache_nowait_percentage
# entry_negative_timeout
# enum_cache_timeout
# fallback_homedir
# filter_users
# filter_groups
# fiter_users_in_groups
# get_domains_timeout
# memcache_timeout
# override_homedir
# override_shell
# reconnection_retries
# user_attributes
# vetoed_shells

class sssd::service::nss {

  include '::sssd'

  # These varaibles are referenced inside the autofs template, and
  # because we don't want to worry about scope inside of the template
  # we handle it here.

  $description                   = $sssd::description
  $debug_level                   = $sssd::debug_level
  $debug_timestamps              = $sssd::debug_timestamps
  $debug_microseconds            = $sssd::debug_microseconds
  $reconnection_retries          = $sssd::reconnection_retries
  $command                       = $sssd::command
  $enum_cache_timeout            = $sssd::enum_cache_timeout
  $entry_cache_nowait_percentage = $sssd::entry_cache_nowait_percentage
  $entry_negative_timeout        = $sssd::entry_negative_timeout
  $filter_users                  = $sssd::filter_users
  $filter_groups                 = $sssd::filter_groups
  $filter_users_in_groups        = $sssd::filter_users_in_groups
  $override_homedir              = $sssd::override_homedir
  $fallback_homedir              = $sssd::fallback_homedir
  $override_shell                = $sssd::override_shell
  $vetoed_shells                 = $sssd::vetoed_shells
  $default_shell                 = $sssd::default_shell
  $get_domains_timeout           = $sssd::get_domains_timeout
  $memcache_timeout              = $sssd::memcache_timeout
  $user_attributes               = $sssd::user_attributes

  concat::fragment { 'sssd_nss.service':
    target  => $sssd::conf_file_path,
    content => template("${module_name}/service/nss.erb")
  }
}
