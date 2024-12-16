# Define: sssd::domain
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
# Full documentation of the parameters that map directly to SSSD
# configuration options can be found in the sssd.conf(5) man page.
#
# @param name
#   The name of the domain.
#   This will be placed at [domain/$name] in the configuration file.
#
# @param id_provider
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param description
# @param min_id
# @param max_id
# @param enumerate
# @param subdomain_enumerate
# @param force_timeout
# @param entry_cache_timeout
# @param entry_cache_user_timeout
# @param entry_cache_group_timeout
# @param entry_cache_netgroup_timeout
# @param entry_cache_service_timeout
# @param entry_cache_sudo_timeout
# @param entry_cache_autofs_timeout
# @param entry_cache_ssh_host_timeout
# @param refresh_expired_interval
# @param cache_credentials
# @param account_cache_expiration
# @param pwd_expiration_warning
# @param use_fully_qualified_names
# @param ignore_group_members
# @param access_provider
# @param auth_provider
# @param chpass_provider
# @param sudo_provider
# @param selinux_provider
# @param subdomains_provider
# @param autofs_provider
# @param hostid_provider
# @param re_expression
# @param full_name_format
# @param lookup_family_order
# @param dns_resolver_timeout
# @param dns_discovery_domain
# @param override_gid
# @param case_sensitive
# @param proxy_fast_alias
# @param realmd_tags
# @param proxy_pam_target
# @param proxy_lib_name
# @param ldap_user_search_filter
# @param ldap_referrals
# @param timeout
# @param ldap_network_timeout
# @param ldap_opt_timeout
# @param ldap_uri
# @param ldap_page_size
# @param ldap_id_use_start_tls
# @param ldap_default_bind_dn
# @param ldap_default_authtok_type
# @param ldap_default_authtok
# @param ldap_tls_reqcert
# @param ldap_schema
# @param ldap_user_search_base
# @param ldap_user_object_class
# @param ldap_user_home_directory
# @param ldap_user_principal
# @param ldap_group_search_base
# @param ldap_group_object_class
# @param ldap_access_order
# @param ldap_account_expire_policy
# @param ldap_force_upper_case_realm
# @param krb5_realm
# @param krb5_canonicalize
# @param override_homedir
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::domain (
  Sssd::IdProvider                           $id_provider,
  Optional[Sssd::DebugLevel]                 $debug_level                  = undef,
  Boolean                                    $debug_timestamps             = true,
  Boolean                                    $debug_microseconds           = false,
  Optional[String]                           $description                  = undef,
  Integer[0]                                 $min_id                       = 1,
  Integer[0]                                 $max_id                       = 0,
  Boolean                                    $enumerate                    = false,
  Boolean                                    $subdomain_enumerate          = false,
  Optional[Integer]                          $force_timeout                = undef,
  Optional[Integer]                          $entry_cache_timeout          = undef,
  Optional[Integer]                          $entry_cache_user_timeout     = undef,
  Optional[Integer]                          $entry_cache_group_timeout    = undef,
  Optional[Integer]                          $entry_cache_netgroup_timeout = undef,
  Optional[Integer]                          $entry_cache_service_timeout  = undef,
  Optional[Integer]                          $entry_cache_sudo_timeout     = undef,
  Optional[Integer]                          $entry_cache_autofs_timeout   = undef,
  Optional[Integer]                          $entry_cache_ssh_host_timeout = undef,
  Optional[Integer]                          $refresh_expired_interval     = undef,
  Boolean                                    $cache_credentials            = false,
  Integer[0]                                 $account_cache_expiration     = 0,
  Optional[Integer[0]]                       $pwd_expiration_warning       = undef,
  Boolean                                    $use_fully_qualified_names    = false,
  Boolean                                    $ignore_group_members         = true,
  Optional[Sssd::AccessProvider]             $access_provider              = undef,
  Optional[Sssd::AuthProvider]               $auth_provider                = undef,
  Optional[Sssd::ChpassProvider]             $chpass_provider              = undef,
  Optional[Enum['ldap', 'ipa','ad','none']]  $sudo_provider                = undef,
  Optional[Enum['ipa', 'none']]              $selinux_provider             = undef,
  Optional[Enum['ipa', 'ad','none']]         $subdomains_provider          = undef,
  Optional[Enum['ad', 'ldap', 'ipa','none']] $autofs_provider              = undef,
  Optional[Enum['ipa', 'none']]              $hostid_provider              = undef,
  Optional[String]                           $re_expression                = undef,
  Optional[String]                           $full_name_format             = undef,
  Optional[String]                           $lookup_family_order          = undef,
  Integer[0]                                 $dns_resolver_timeout         = 5,
  Optional[String]                           $dns_discovery_domain         = undef,
  Optional[String]                           $override_gid                 = undef,
  Variant[Boolean,Enum['preserving']]        $case_sensitive               = true,
  Boolean                                    $proxy_fast_alias             = false,
  Optional[String]                           $realmd_tags                  = undef,
  Optional[String]                           $proxy_pam_target             = undef,
  Optional[String]                           $proxy_lib_name               = undef,
  Optional[String]                           $ldap_user_search_filter      = undef,
  Optional[Boolean]                          $ldap_referrals               = undef,
  Optional[Integer[0]]                       $timeout                      = undef,
  Optional[Integer[0]]                       $ldap_network_timeout         = undef,
  Optional[Integer[0]]                       $ldap_opt_timeout             = undef,
  Optional[String]                           $ldap_uri                     = undef,
  Optional[Integer[0]]                       $ldap_page_size               = undef,
  Optional[Boolean]                          $ldap_id_use_start_tls        = undef,
  Optional[String]                           $ldap_default_bind_dn         = undef,
  Optional[String]                           $ldap_default_authtok_type    = undef,
  Optional[String]                           $ldap_default_authtok         = undef,
  Optional[String]                           $ldap_tls_reqcert             = undef,
  Optional[String]                           $ldap_schema                  = undef,
  Optional[String]                           $ldap_user_search_base        = undef,
  Optional[String]                           $ldap_user_object_class       = undef,
  Optional[String]                           $ldap_user_home_directory     = undef,
  Optional[String]                           $ldap_user_principal          = undef,
  Optional[String]                           $ldap_group_search_base       = undef,
  Optional[String]                           $ldap_group_object_class      = undef,
  Optional[String]                           $ldap_access_order            = undef,
  Optional[String]                           $ldap_account_expire_policy   = undef,
  Optional[Boolean]                          $ldap_force_upper_case_realm  = undef,
  Optional[String]                           $krb5_realm                   = undef,
  Optional[Boolean]                          $krb5_canonicalize            = undef,
  Optional[String]                           $override_homedir             = undef,
) {

  sssd::config::entry { "puppet_domain_${name}":
    content => template('sssd/domain.erb')
  }
}
