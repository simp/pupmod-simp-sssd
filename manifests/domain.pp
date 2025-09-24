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
  Optional[Hash]                             $custom_options               = undef,
) {
  # Build configuration lines in order (matching expected test output)
  # Debug settings
  $debug_level_line = $debug_level ? { undef => [], default => ["debug_level = ${debug_level}"] }
  $debug_timestamps_line = ["debug_timestamps = ${debug_timestamps}"]
  $debug_microseconds_line = ["debug_microseconds = ${debug_microseconds}"]

  # Description and basic settings
  $description_line = $description ? { undef => [], default => ["description = ${description}"] }
  $min_id_line = ["min_id = ${min_id}"]
  $max_id_line = ["max_id = ${max_id}"]
  $enumerate_line = ["enumerate = ${enumerate}"]

  # Subdomain and timeout settings
  $subdomain_enumerate_line = $subdomain_enumerate ? { false => [], default => ["subdomain_enumerate = ${subdomain_enumerate}"] }
  $force_timeout_line = $force_timeout ? { undef => [], default => ["force_timeout = ${force_timeout}"] }

  # Entry cache timeout settings
  $entry_cache_timeout_line = $entry_cache_timeout ? { undef => [], default => ["entry_cache_timeout = ${entry_cache_timeout}"] }
  $entry_cache_user_timeout_line = $entry_cache_user_timeout ? { undef => [], default => ["entry_cache_user_timeout = ${entry_cache_user_timeout}"] }
  $entry_cache_group_timeout_line = $entry_cache_group_timeout ? { undef => [], default => ["entry_cache_group_timeout = ${entry_cache_group_timeout}"] }
  $entry_cache_netgroup_timeout_line = $entry_cache_netgroup_timeout ? { undef => [], default => ["entry_cache_netgroup_timeout = ${entry_cache_netgroup_timeout}"] }
  $entry_cache_service_timeout_line = $entry_cache_service_timeout ? { undef => [], default => ["entry_cache_service_timeout = ${entry_cache_service_timeout}"] }
  $entry_cache_sudo_timeout_line = $entry_cache_sudo_timeout ? { undef => [], default => ["entry_cache_sudo_timeout = ${entry_cache_sudo_timeout}"] }
  $entry_cache_autofs_timeout_line = $entry_cache_autofs_timeout ? { undef => [], default => ["entry_cache_autofs_timeout = ${entry_cache_autofs_timeout}"] }
  $entry_cache_ssh_host_timeout_line = $entry_cache_ssh_host_timeout ? { undef => [], default => ["entry_cache_ssh_host_timeout = ${entry_cache_ssh_host_timeout}"] }
  $refresh_expired_interval_line = $refresh_expired_interval ? { undef => [], default => ["refresh_expired_interval = ${refresh_expired_interval}"] }

  # Cache settings
  $cache_credentials_line = ["cache_credentials = ${cache_credentials}"]
  $account_cache_expiration_line = ["account_cache_expiration = ${account_cache_expiration}"]
  $pwd_expiration_warning_line = $pwd_expiration_warning ? { undef => [], default => ["pwd_expiration_warning = ${pwd_expiration_warning}"] }

  # Naming settings
  $use_fully_qualified_names_line = ["use_fully_qualified_names = ${use_fully_qualified_names}"]
  $ignore_group_members_line = ["ignore_group_members = ${ignore_group_members}"]

  # Provider settings (id_provider is required, others optional)
  $id_provider_line = ["id_provider = ${id_provider}"]
  $auth_provider_line = $auth_provider ? { undef => [], default => ["auth_provider = ${auth_provider}"] }
  $access_provider_line = $access_provider ? { undef => [], default => ["access_provider = ${access_provider}"] }
  $chpass_provider_line = $chpass_provider ? { undef => [], default => ["chpass_provider = ${chpass_provider}"] }
  $sudo_provider_line = $sudo_provider ? { undef => [], default => ["sudo_provider = ${sudo_provider}"] }
  $selinux_provider_line = $selinux_provider ? { undef => [], default => ["selinux_provider = ${selinux_provider}"] }
  $subdomains_provider_line = $subdomains_provider ? { undef => [], default => ["subdomains_provider = ${subdomains_provider}"] }
  $autofs_provider_line = $autofs_provider ? { undef => [], default => ["autofs_provider = ${autofs_provider}"] }
  $hostid_provider_line = $hostid_provider ? { undef => [], default => ["hostid_provider = ${hostid_provider}"] }

  # Pattern and formatting settings
  $re_expression_line = $re_expression ? { undef => [], default => ["re_expression = ${re_expression}"] }
  $full_name_format_line = $full_name_format ? { undef => [], default => ["full_name_format = ${full_name_format}"] }
  $lookup_family_order_line = $lookup_family_order ? { undef => [], default => ["lookup_family_order = ${lookup_family_order}"] }

  # DNS settings
  $dns_resolver_timeout_line = ["dns_resolver_timeout = ${dns_resolver_timeout}"]
  $dns_discovery_domain_line = $dns_discovery_domain ? { undef => [], default => ["dns_discovery_domain = ${dns_discovery_domain}"] }

  # Override and case sensitivity settings
  $override_gid_line = $override_gid ? { undef => [], default => ["override_gid = ${override_gid}"] }
  $case_sensitive_line = ["case_sensitive = ${case_sensitive}"]
  $proxy_fast_alias_line = ["proxy_fast_alias = ${proxy_fast_alias}"]

  # Optional provider-specific settings
  $realmd_tags_line = $realmd_tags ? { undef => [], default => ["realmd_tags = ${realmd_tags}"] }
  $ldap_user_search_filter_line = $ldap_user_search_filter ? { undef => [], default => ["ldap_user_search_filter = ${ldap_user_search_filter}"] }
  $proxy_pam_target_line = $proxy_pam_target ? { undef => [], default => ["proxy_pam_target = ${proxy_pam_target}"] }
  $proxy_lib_name_line = $proxy_lib_name ? { undef => [], default => ["proxy_lib_name = ${proxy_lib_name}"] }

  # Custom options processing
  $custom_options_lines = $custom_options ? {
    undef => [],
    default => $custom_options.keys.sort.map |$opt| { "${opt} = ${custom_options[$opt]}" }
  }

  # Combine all lines in order
  $config_lines = (
    $debug_level_line +
    $debug_timestamps_line +
    $debug_microseconds_line +
    $description_line +
    $min_id_line +
    $max_id_line +
    $enumerate_line +
    $subdomain_enumerate_line +
    $force_timeout_line +
    $entry_cache_timeout_line +
    $entry_cache_user_timeout_line +
    $entry_cache_group_timeout_line +
    $entry_cache_netgroup_timeout_line +
    $entry_cache_service_timeout_line +
    $entry_cache_sudo_timeout_line +
    $entry_cache_autofs_timeout_line +
    $entry_cache_ssh_host_timeout_line +
    $refresh_expired_interval_line +
    $cache_credentials_line +
    $account_cache_expiration_line +
    $pwd_expiration_warning_line +
    $use_fully_qualified_names_line +
    $ignore_group_members_line +
    $id_provider_line +
    $auth_provider_line +
    $access_provider_line +
    $chpass_provider_line +
    $sudo_provider_line +
    $selinux_provider_line +
    $subdomains_provider_line +
    $autofs_provider_line +
    $hostid_provider_line +
    $re_expression_line +
    $full_name_format_line +
    $lookup_family_order_line +
    $dns_resolver_timeout_line +
    $dns_discovery_domain_line +
    $override_gid_line +
    $case_sensitive_line +
    $proxy_fast_alias_line +
    $realmd_tags_line +
    $ldap_user_search_filter_line +
    $proxy_pam_target_line +
    $proxy_lib_name_line +
    $custom_options_lines
  )

  # Join all configuration lines
  $content = $config_lines.join("\n")

  sssd::config::entry { "puppet_domain_${name}":
    content => epp('sssd/domain.epp', {
        'name'    => $name,
        'content' => $content,
    }),
  }
}
