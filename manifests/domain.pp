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
# [*id_provider*]
# [*min_id*]
# [*max_id*]
# [*description*]
# [*auth_provider*]
# [*access_provider*]
# [*chpass_provider*]
# [*domain_timeout*]
# [*enumerate*]
# [*entry_cache_timeout*]
# [*cache_credentials*]
# [*account_cache_expiration*]
# [*use_fully_qualified_names*]
# [*lookup_family_order*]
# [*dns_resolver_timeout*]
# [*dns_discovery_domain*]
# [*proxy_pam_target*]
# [*proxy_lib_name*]
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define sssd::domain (
  $id_provider,
  $min_id = '1',
  $max_id = '0',
  $description = '',
  $auth_provider = '',
  $access_provider = '',
  $chpass_provider = '',
  $domain_timeout = '10',
  $enumerate = false,
  $entry_cache_timeout = '5400',
  $cache_credentials = false,
  $account_cache_expiration = '0',
  $use_fully_qualified_names = '',
  $lookup_family_order = '',
  $dns_resolver_timeout = '5',
  $dns_discovery_domain = '',
  $proxy_pam_target = '',
  $proxy_lib_name = ''
) {

  concat_fragment { "sssd+${name}#.domain":
    content => template('sssd/domain.erb')
  }

  validate_integer($min_id)
  validate_integer($max_id)
  validate_integer($domain_timeout)
  validate_bool($enumerate)
  validate_integer($entry_cache_timeout)
  validate_bool($cache_credentials)
  validate_integer($account_cache_expiration)
  if !empty($use_fully_qualified_names) { validate_bool($use_fully_qualified_names) }
  validate_integer($dns_resolver_timeout)
}
