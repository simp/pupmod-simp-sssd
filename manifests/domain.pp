# == Define: sssd::domain
#
# This define sets up a domain section of /etc/sssd.conf. This domain will be
# named after '$name' and should be listed in your main sssd.conf if you wish
# to activate it.
#
# You will need to call the associated provider segments to make this fully
# functional.
#
# It is entirely possible to make a configuration file that is complete
# nonsense by failing to set the correct combinations of providers. See the
# SSSD documentation for details.
#
# When you call the associated providers, you should be sure to name them based
# on the name of this domain.
#
# == Parameters
#
# [*name*]
#   The name of the domain.
#   This will be placed at [domain/$name] in the configuration file.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define sssd::domain (
  $id_provider,
  $debug_level = '',
  $debug_timestamps = '',
  $debug_microseconds = '',
  $description = '',
  $min_id = $::uid_min,
  $max_id = '0',
  $enumerate = false,
  $subdomain_enumerate = '',
  $force_timeout = '',
  $entry_cache_timeout = '',
  $entry_cache_user_timeout = '',
  $entry_cache_group_timeout = '',
  $entry_cache_netgroup_timeout = '',
  $entry_cache_service_timeout = '',
  $entry_cache_sudo_timeout = '',
  $entry_cache_autofs_timeout = '',
  $entry_cache_ssh_host_timeout = '',
  $refresh_expired_interval = '',
  $cache_credentials = false,
  $account_cache_expiration = '0',
  $pwd_expiration_warning = '',
  $use_fully_qualified_names = '',
  $ignore_group_members = '',
  $auth_provider = '',
  $access_provider = '',
  $chpass_provider = '',
  $sudo_provider = '',
  $selinux_provider = '',
  $subdomains_provider = '',
  $autofs_provider = '',
  $hostid_provider = '',
  $re_expression = '',
  $full_name_format = '',
  $lookup_family_order = '',
  $dns_resolver_timeout = '5',
  $dns_discovery_domain = '',
  $override_gid = '',
  $case_sensitive = '',
  $proxy_fast_alias = '',
  $realmd_tags = '',
  $proxy_pam_target = '',
  $proxy_lib_name = ''
) {

  validate_string($id_provider)
  validate_array_member($id_provider,['proxy','local','ldap','ipa','ad'])
  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
  validate_integer($min_id)
  validate_integer($max_id)
  validate_bool($enumerate)
  validate_string($subdomain_enumerate)
  unless empty($subdomain_enumerate) { validate_array_member($subdomain_enumerate,['all','none']) }
  unless empty($force_timeout) { validate_integer($force_timeout) }
  unless empty($entry_cache_timeout) { validate_integer($entry_cache_timeout) }
  unless empty($entry_cache_user_timeout) { validate_integer($entry_cache_user_timeout) }
  unless empty($entry_cache_group_timeout) { validate_integer($entry_cache_group_timeout) }
  unless empty($entry_cache_netgroup_timeout) { validate_integer($entry_cache_netgroup_timeout) }
  unless empty($entry_cache_service_timeout) { validate_integer($entry_cache_service_timeout) }
  unless empty($entry_cache_sudo_timeout) { validate_integer($entry_cache_sudo_timeout) }
  unless empty($entry_cache_autofs_timeout) { validate_integer($entry_cache_autofs_timeout) }
  unless empty($entry_cache_ssh_host_timeout) { validate_integer($entry_cache_ssh_host_timeout) }
  unless empty($refresh_expired_interval) { validate_integer($refresh_expired_interval) }
  validate_bool($cache_credentials)
  validate_integer($account_cache_expiration)
  unless empty($pwd_expiration_warning) { validate_integer($pwd_expiration_warning) }
  unless empty($use_fully_qualified_names) { validate_bool($use_fully_qualified_names) }
  unless empty($ignore_group_members) { validate_bool($ignore_group_members) }
  validate_string($auth_provider)
  unless empty($auth_provider) { validate_array_member($auth_provider,['ldap','krb5','ipa','ad','proxy','local','none']) }
  validate_string($access_provider)
  unless empty($access_provider) { validate_array_member($access_provider,['permit','deny','ldap','ipa','ad','simple']) }
  validate_string($chpass_provider)
  unless empty($chpass_provider) { validate_array_member($chpass_provider,['ldap','krb5','ipa','ad','proxy','none']) }
  validate_string($sudo_provider)
  unless empty($sudo_provider) { validate_array_member($sudo_provider,['ldap','ipa','ad','none']) }
  validate_string($selinux_provider)
  unless empty($selinux_provider) { validate_array_member($selinux_provider,['ipa','none']) }
  validate_string($subdomains_provider)
  unless empty($subdomains_provider) { validate_array_member($subdomains_provider,['ipa','ad','none']) }
  validate_string($autofs_provider)
  unless empty($autofs_provider) { validate_array_member($autofs_provider,['ldap','ipa','none']) }
  validate_string($hostid_provider)
  unless empty($hostid_provider) { validate_array_member($hostid_provider,['ipa','none']) }
  validate_string($re_expression)
  validate_string($full_name_format)
  validate_string($lookup_family_order)
  unless empty($lookup_family_order) { validate_array_member($lookup_family_order,['ipv4_first','ipv4_only','ipv6_first','ipv6_only']) }
  validate_integer($dns_resolver_timeout)
  validate_string($dns_discovery_domain)
  validate_string($override_gid)
  validate_string($case_sensitive)
  unless empty($case_sensitive) { validate_array_member($case_sensitive,['true','false','preserving']) }
  unless empty($proxy_fast_alias) { validate_bool($proxy_fast_alias) }
  validate_string($realmd_tags)
  validate_string($proxy_pam_target)
  validate_string($proxy_lib_name)

  simpcat_fragment { "sssd+${name}#.domain":
    content => template('sssd/domain.erb')
  }

}
