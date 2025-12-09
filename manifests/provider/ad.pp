# @summary Set up the 'ad' (Active Directory) id_provider section of a particular domain.
#
# NOTE: You MUST connect the system to the domain prior to using this defined type.
#
# Any parameter not explicitly documented directly follows the documentation
# from sssd-ad(5).
#
# @see sssd-ad(5)
#
# @attr name [String]
#   The name of the associated domain section in the configuration file
#
# @param ad_domain
#
# @param ad_enabled_domains
#   An explicit list of AD enabled domains
#
#   * An error will be raised if ``ad_domain`` is specified and not in this
#     list
#
# @param ad_servers
#   A list of AD servers in failover order
#
#   * Ignored if ``autodiscovery`` is enabled
#
# @param ad_backup_servers
#   A list of AD backup servers in failover order
#
#   * Ignored if ``autodiscovery`` is enabled
#
# @param ad_hostname
# @param ad_enable_dns_sites
#
# @param ad_access_filters
#   A list of access filters for the system
#
# @param ad_site
# @param ad_enable_gc
# @param ad_gpo_access_control
# @param ad_gpo_cache_timeout
# @param ad_gpo_map_interactive
# @param ad_gpo_map_remote_interactive
# @param ad_gpo_map_network
# @param ad_gpo_map_batch
# @param ad_gpo_map_service
# @param ad_gpo_map_permit
# @param ad_gpo_map_deny
# @param ad_gpo_default_right
# @param ad_gpo_implicit_deny
#        (new in sssd V2.0 and later)
# @param ad_gpo_ignore_unreadable
#        (new in sssd V2.0 and later)
# @param ad_maximum_machine_account_password_age
# @param ad_machine_account_password_renewal_opts
# @param default_shell
# @param dyndns_update
# @param dyndns_ttl
#
# @param dyndns_ifaces
#   List of interfaces whose IP Addresses should be used for dynamic DNS
#   updates.  Used for the dyndns_iface setting.
#
#   * Has no effect if ``dyndns_update`` is not set to ``true``
#
# @param dyndns_refresh_interval
# @param dyndns_update_ptr
# @param dyndns_force_tcp
# @param dyndns_server
# @param override_homedir
# @param fallback_homedir
# @param homedir_substring
# @param krb5_realm
# @param krb5_use_enterprise_principal
# @param krb5_store_password_if_offline
# @param krb5_confd_path
# @param ldap_id_mapping
# @param ldap_schema
# @param ldap_idmap_range_min
# @param ldap_idmap_range_max
# @param ldap_idmap_range_size
# @param ldap_idmap_default_domain_sid
# @param ldap_idmap_default_domain
# @param ldap_idmap_autorid_compat
# @param ldap_idmap_helper_table_size
# @param ldap_use_tokengroups
# @param ldap_group_objectsid
# @param ldap_user_objectsid
# @param ldap_user_extra_attrs
#   Can be used to enable public key storage for ssh
#   When used this way, set this param and param ldap_user_ssh_public_key
#   to 'altSecurityIdentities'
# @param ldap_user_ssh_public_key
#   Can be used to enable public key storage for ssh
#   When used this way, set this param and param ldap_user_extra_attrs
#   to 'altSecurityIdentities'
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::provider::ad (
  Optional[String[1]]                                        $ad_domain                                = undef,
  Optional[Array[String[1],1]]                               $ad_enabled_domains                       = undef,
  Optional[Array[Variant[Simplib::Hostname, Enum['_srv_']]]] $ad_servers                               = undef,
  Optional[Array[Simplib::Hostname,1]]                       $ad_backup_servers                        = undef,
  Optional[Simplib::Hostname]                                $ad_hostname                              = undef,
  Optional[Boolean]                                          $ad_enable_dns_sites                      = undef,
  Optional[Array[String[1],1]]                               $ad_access_filters                        = undef,
  Optional[String[1]]                                        $ad_site                                  = undef,
  Optional[Boolean]                                          $ad_enable_gc                             = undef,
  Optional[Enum['disabled','enforcing','permissive']]        $ad_gpo_access_control                    = undef,
  Optional[Integer[1]]                                       $ad_gpo_cache_timeout                     = undef,
  Optional[Array[String[1],1]]                               $ad_gpo_map_interactive                   = undef,
  Optional[Array[String[1],1]]                               $ad_gpo_map_remote_interactive            = undef,
  Optional[Array[String[1],1]]                               $ad_gpo_map_network                       = undef,
  Optional[Array[String[1],1]]                               $ad_gpo_map_batch                         = undef,
  Optional[Array[String[1],1]]                               $ad_gpo_map_service                       = undef,
  Optional[Array[String[1],1]]                               $ad_gpo_map_permit                        = undef,
  Optional[Array[String[1],1]]                               $ad_gpo_map_deny                          = undef,
  Optional[Sssd::ADDefaultRight]                             $ad_gpo_default_right                     = undef,
  Optional[Boolean]                                          $ad_gpo_implicit_deny                     = undef,
  Optional[Boolean]                                          $ad_gpo_ignore_unreadable                 = undef,
  Optional[Integer[0]]                                       $ad_maximum_machine_account_password_age  = undef,
  Optional[Pattern['^\d+:\d+$']]                             $ad_machine_account_password_renewal_opts = undef,
  Optional[String[1]]                                        $default_shell                            = undef,
  Boolean                                                    $dyndns_update                            = true,
  Optional[Integer]                                          $dyndns_ttl                               = undef,
  Optional[Array[String[1],1]]                               $dyndns_ifaces                            = undef,
  Optional[Integer]                                          $dyndns_refresh_interval                  = undef,
  Optional[Boolean]                                          $dyndns_update_ptr                        = undef,
  Optional[Boolean]                                          $dyndns_force_tcp                         = undef,
  Optional[Simplib::Hostname]                                $dyndns_server                            = undef,
  Optional[String[1]]                                        $override_homedir                         = undef,
  Optional[String[1]]                                        $fallback_homedir                         = undef,
  Optional[Stdlib::Absolutepath]                             $homedir_substring                        = undef,
  Optional[String[1]]                                        $krb5_realm                               = $ad_domain,
  Optional[Variant[Enum['none'],Stdlib::Absolutepath]]       $krb5_confd_path                          = undef,
  Optional[Boolean]                                          $krb5_use_enterprise_principal            = undef,
  Boolean                                                    $krb5_store_password_if_offline           = false,
  Boolean                                                    $ldap_id_mapping                          = true,
  Optional[String[1]]                                        $ldap_schema                              = undef,
  Optional[Integer[0]]                                       $ldap_idmap_range_min                     = undef,
  Optional[Integer[1]]                                       $ldap_idmap_range_max                     = undef,
  Optional[Integer[1]]                                       $ldap_idmap_range_size                    = undef,
  Optional[String[1]]                                        $ldap_idmap_default_domain_sid            = undef,
  Optional[String[1]]                                        $ldap_idmap_default_domain                = undef,
  Optional[Boolean]                                          $ldap_idmap_autorid_compat                = undef,
  Optional[Integer[1]]                                       $ldap_idmap_helper_table_size             = undef,
  Boolean                                                    $ldap_use_tokengroups                     = true,
  Optional[String[1]]                                        $ldap_group_objectsid                     = undef,
  Optional[String[1]]                                        $ldap_user_objectsid                      = undef,
  Optional[String[1]]                                        $ldap_user_extra_attrs                    = undef,
  Optional[String[1]]                                        $ldap_user_ssh_public_key                 = undef,
) {
  # Create parameter hash for easier access
  $param_values = {
    'ad_domain'                                => $ad_domain,
    'ad_enabled_domains'                       => $ad_enabled_domains,
    'ad_servers'                               => $ad_servers,
    'ad_backup_servers'                        => $ad_backup_servers,
    'ad_hostname'                              => $ad_hostname,
    'ad_enable_dns_sites'                      => $ad_enable_dns_sites,
    'ad_access_filters'                        => $ad_access_filters,
    'ad_site'                                  => $ad_site,
    'ad_enable_gc'                             => $ad_enable_gc,
    'ad_gpo_access_control'                    => $ad_gpo_access_control,
    'ad_gpo_cache_timeout'                     => $ad_gpo_cache_timeout,
    'ad_gpo_map_interactive'                   => $ad_gpo_map_interactive,
    'ad_gpo_map_remote_interactive'            => $ad_gpo_map_remote_interactive,
    'ad_gpo_map_network'                       => $ad_gpo_map_network,
    'ad_gpo_map_batch'                         => $ad_gpo_map_batch,
    'ad_gpo_map_service'                       => $ad_gpo_map_service,
    'ad_gpo_map_permit'                        => $ad_gpo_map_permit,
    'ad_gpo_map_deny'                          => $ad_gpo_map_deny,
    'ad_gpo_default_right'                     => $ad_gpo_default_right,
    'ad_gpo_implicit_deny'                     => $ad_gpo_implicit_deny,
    'ad_gpo_ignore_unreadable'                 => $ad_gpo_ignore_unreadable,
    'ad_maximum_machine_account_password_age'  => $ad_maximum_machine_account_password_age,
    'ad_machine_account_password_renewal_opts' => $ad_machine_account_password_renewal_opts,
    'default_shell'                            => $default_shell,
    'override_homedir'                         => $override_homedir,
    'fallback_homedir'                         => $fallback_homedir,
    'homedir_substring'                        => $homedir_substring,
    'krb5_realm'                               => $krb5_realm,
    'krb5_confd_path'                          => $krb5_confd_path,
    'krb5_use_enterprise_principal'            => $krb5_use_enterprise_principal,
    'krb5_store_password_if_offline'           => $krb5_store_password_if_offline,
    'ldap_id_mapping'                          => $ldap_id_mapping,
    'ldap_schema'                              => $ldap_schema,
    'ldap_idmap_range_min'                     => $ldap_idmap_range_min,
    'ldap_idmap_range_max'                     => $ldap_idmap_range_max,
    'ldap_idmap_range_size'                    => $ldap_idmap_range_size,
    'ldap_idmap_default_domain_sid'            => $ldap_idmap_default_domain_sid,
    'ldap_idmap_default_domain'                => $ldap_idmap_default_domain,
    'ldap_idmap_autorid_compat'                => $ldap_idmap_autorid_compat,
    'ldap_idmap_helper_table_size'             => $ldap_idmap_helper_table_size,
    'ldap_use_tokengroups'                     => $ldap_use_tokengroups,
    'ldap_group_objectsid'                     => $ldap_group_objectsid,
    'ldap_user_objectsid'                      => $ldap_user_objectsid,
    'ldap_user_extra_attrs'                    => $ldap_user_extra_attrs,
    'ldap_user_ssh_public_key'                 => $ldap_user_ssh_public_key,
  }

  # Build configuration lines array (order matches expected test output)
  $ad_domain_line = $ad_domain ? { undef => [], default => ["ad_domain = ${ad_domain}"] }
  $ad_enabled_domains_line = $ad_enabled_domains ? { undef => [], default => ["ad_enabled_domains = ${ad_enabled_domains.join(', ')}"] }

  $ad_server_lines = $ad_servers ? {
    undef => [],
    default => ["ad_server = ${ad_servers.join(', ')}"] + ($ad_backup_servers ? { undef => [], default => ["ad_backup_server = ${ad_backup_servers.join(', ')}"] })
  }

  $ad_hostname_line = $ad_hostname ? { undef => [], default => ["ad_hostname = ${ad_hostname}"] }
  $ad_enable_dns_sites_line = $ad_enable_dns_sites ? { undef => [], default => ["ad_enable_dns_sites = ${ad_enable_dns_sites}"] }
  $ad_access_filters_line = $ad_access_filters ? { undef => [], default => ["ad_access_filter = ${ad_access_filters.join('?')}"] }
  $ad_site_line = $ad_site ? { undef => [], default => ["ad_site = ${ad_site}"] }
  $ad_enable_gc_line = $ad_enable_gc ? { undef => [], default => ["ad_enable_gc = ${ad_enable_gc}"] }

  # GPO parameters
  $ad_gpo_access_control_line = $ad_gpo_access_control ? { undef => [], default => ["ad_gpo_access_control = ${ad_gpo_access_control}"] }
  $ad_gpo_cache_timeout_line = $ad_gpo_cache_timeout ? { undef => [], default => ["ad_gpo_cache_timeout = ${ad_gpo_cache_timeout}"] }
  $ad_gpo_map_interactive_line = $ad_gpo_map_interactive ? { undef => [], default => ["ad_gpo_map_interactive = ${ad_gpo_map_interactive.join(', ')}"] }
  $ad_gpo_map_remote_interactive_line = $ad_gpo_map_remote_interactive ? { undef => [], default => ["ad_gpo_map_remote_interactive = ${ad_gpo_map_remote_interactive.join(', ')}"] }
  $ad_gpo_map_network_line = $ad_gpo_map_network ? { undef => [], default => ["ad_gpo_map_network = ${ad_gpo_map_network.join(', ')}"] }
  $ad_gpo_map_batch_line = $ad_gpo_map_batch ? { undef => [], default => ["ad_gpo_map_batch = ${ad_gpo_map_batch.join(', ')}"] }
  $ad_gpo_map_service_line = $ad_gpo_map_service ? { undef => [], default => ["ad_gpo_map_service = ${ad_gpo_map_service.join(', ')}"] }
  $ad_gpo_map_permit_line = $ad_gpo_map_permit ? { undef => [], default => ["ad_gpo_map_permit = ${ad_gpo_map_permit.join(', ')}"] }
  $ad_gpo_map_deny_line = $ad_gpo_map_deny ? { undef => [], default => ["ad_gpo_map_deny = ${ad_gpo_map_deny.join(', ')}"] }
  $ad_gpo_default_right_line = $ad_gpo_default_right ? { undef => [], default => ["ad_gpo_default_right = ${ad_gpo_default_right}"] }
  $ad_gpo_implicit_deny_line = $ad_gpo_implicit_deny ? { undef => [], default => ["ad_gpo_implicit_deny = ${ad_gpo_implicit_deny}"] }
  $ad_gpo_ignore_unreadable_line = $ad_gpo_ignore_unreadable ? { undef => [], default => ["ad_gpo_ignore_unreadable = ${ad_gpo_ignore_unreadable}"] }

  # Machine account parameters
  $ad_maximum_machine_account_password_age_line = $ad_maximum_machine_account_password_age ? { undef => [], default => ["ad_maximum_machine_account_password_age = ${ad_maximum_machine_account_password_age}"] }
  $ad_machine_account_password_renewal_opts_line = $ad_machine_account_password_renewal_opts ? { undef => [], default => ["ad_machine_account_password_renewal_opts = ${ad_machine_account_password_renewal_opts}"] }

  # General parameters
  $default_shell_line = $default_shell ? { undef => [], default => ["default_shell = ${default_shell}"] }

  # Dynamic DNS parameters
  $dyndns_update_line = $dyndns_update ? { undef => [], default => ["dyndns_update = ${dyndns_update}"] }
  $dyndns_conditional_lines = $dyndns_update ? {
    true => (
      ($dyndns_ttl ? { undef => [], default => ["dyndns_ttl = ${dyndns_ttl}"] }) +
      ($dyndns_ifaces ? { undef => [], default => ["dyndns_iface = ${dyndns_ifaces.join(', ')}"] }) +
      ($dyndns_refresh_interval ? { undef => [], default => ["dyndns_refresh_interval = ${dyndns_refresh_interval}"] }) +
      ($dyndns_update_ptr ? { undef => [], default => ["dyndns_update_ptr = ${dyndns_update_ptr}"] }) +
      ($dyndns_force_tcp ? { undef => [], default => ["dyndns_force_tcp = ${dyndns_force_tcp}"] }) +
      ($dyndns_server ? { undef => [], default => ["dyndns_server = ${dyndns_server}"] })
    ),
    default => []
  }

  # Home directory parameters
  $override_homedir_line = $override_homedir ? { undef => [], default => ["override_homedir = ${override_homedir}"] }
  $homedir_substring_line = $homedir_substring ? { undef => [], default => ["homedir_substring = ${homedir_substring}"] }
  $fallback_homedir_line = $fallback_homedir ? { undef => [], default => ["fallback_homedir = ${fallback_homedir}"] }

  # Kerberos parameters
  $krb5_realm_line = $krb5_realm ? { undef => [], default => ["krb5_realm = ${krb5_realm}"] }
  $krb5_confd_path_line = $krb5_confd_path ? { undef => [], default => ["krb5_confd_path = ${krb5_confd_path}"] }
  $krb5_use_enterprise_principal_line = $krb5_use_enterprise_principal ? { undef => [], default => ["krb5_use_enterprise_principal = ${krb5_use_enterprise_principal}"] }
  $krb5_store_password_if_offline_line = $krb5_store_password_if_offline ? { undef => [], default => ["krb5_store_password_if_offline = ${krb5_store_password_if_offline}"] }

  # LDAP ID mapping (always present)
  $ldap_id_mapping_line = ["ldap_id_mapping = ${ldap_id_mapping}"]
  $ldap_idmap_conditional_lines = $ldap_id_mapping ? {
    true => (
      ($ldap_schema ? { undef => [], default => ["ldap_schema = ${ldap_schema}"] }) +
      ($ldap_idmap_range_min ? { undef => [], default => ["ldap_idmap_range_min = ${ldap_idmap_range_min}"] }) +
      ($ldap_idmap_range_max ? { undef => [], default => ["ldap_idmap_range_max = ${ldap_idmap_range_max}"] }) +
      ($ldap_idmap_range_size ? { undef => [], default => ["ldap_idmap_range_size = ${ldap_idmap_range_size}"] }) +
      ($ldap_idmap_default_domain_sid ? { undef => [], default => ["ldap_idmap_default_domain_sid = ${ldap_idmap_default_domain_sid}"] }) +
      ($ldap_idmap_default_domain ? { undef => [], default => ["ldap_idmap_default_domain = ${ldap_idmap_default_domain}"] }) +
      ($ldap_idmap_autorid_compat ? { undef => [], default => ["ldap_idmap_autorid_compat = ${ldap_idmap_autorid_compat}"] }) +
      ($ldap_idmap_helper_table_size ? { undef => [], default => ["ldap_idmap_helper_table_size = ${ldap_idmap_helper_table_size}"] })
    ),
    default => []
  }

  # LDAP parameters (always present)
  $ldap_use_tokengroups_line = ["ldap_use_tokengroups = ${ldap_use_tokengroups}"]
  $ldap_group_objectsid_line = $ldap_group_objectsid ? { undef => [], default => ["ldap_group_objectsid = ${ldap_group_objectsid}"] }
  $ldap_user_objectsid_line = $ldap_user_objectsid ? { undef => [], default => ["ldap_user_objectsid = ${ldap_user_objectsid}"] }
  $ldap_user_extra_attrs_line = $ldap_user_extra_attrs ? { undef => [], default => ["ldap_user_extra_attrs = ${ldap_user_extra_attrs}"] }
  $ldap_user_ssh_public_key_line = $ldap_user_ssh_public_key ? { undef => [], default => ["ldap_user_ssh_public_key = ${ldap_user_ssh_public_key}"] }

  # Combine all lines in order
  $config_lines = (
    $ad_domain_line +
    $ad_enabled_domains_line +
    $ad_server_lines +
    $ad_hostname_line +
    $ad_enable_dns_sites_line +
    $ad_access_filters_line +
    $ad_site_line +
    $ad_enable_gc_line +
    $ad_gpo_access_control_line +
    $ad_gpo_cache_timeout_line +
    $ad_gpo_map_interactive_line +
    $ad_gpo_map_remote_interactive_line +
    $ad_gpo_map_network_line +
    $ad_gpo_map_batch_line +
    $ad_gpo_map_service_line +
    $ad_gpo_map_permit_line +
    $ad_gpo_map_deny_line +
    $ad_gpo_default_right_line +
    $ad_gpo_implicit_deny_line +
    $ad_gpo_ignore_unreadable_line +
    $ad_maximum_machine_account_password_age_line +
    $ad_machine_account_password_renewal_opts_line +
    $default_shell_line +
    $dyndns_update_line +
    $dyndns_conditional_lines +
    $override_homedir_line +
    $homedir_substring_line +
    $fallback_homedir_line +
    $krb5_realm_line +
    $krb5_confd_path_line +
    $krb5_use_enterprise_principal_line +
    $krb5_store_password_if_offline_line +
    $ldap_id_mapping_line +
    $ldap_idmap_conditional_lines +
    $ldap_use_tokengroups_line +
    $ldap_group_objectsid_line +
    $ldap_user_objectsid_line +
    $ldap_user_extra_attrs_line +
    $ldap_user_ssh_public_key_line
  )

  # Boolean parameters that should always be output
  $boolean_params = {
    'dyndns_update'                         => $dyndns_update,
    'krb5_store_password_if_offline'        => $krb5_store_password_if_offline,
    'ldap_id_mapping'                       => $ldap_id_mapping,
    'ldap_use_tokengroups'                  => $ldap_use_tokengroups,
  }

  # Optional boolean parameters (only output if not undef)
  $optional_boolean_params = {
    'ad_enable_dns_sites'           => $ad_enable_dns_sites,
    'ad_enable_gc'                  => $ad_enable_gc,
    'ad_gpo_implicit_deny'          => $ad_gpo_implicit_deny,
    'ad_gpo_ignore_unreadable'      => $ad_gpo_ignore_unreadable,
    'krb5_use_enterprise_principal' => $krb5_use_enterprise_principal,
    'ldap_idmap_autorid_compat'     => $ldap_idmap_autorid_compat,
  }

  # Array parameters with different separators and special handling
  $array_params = {
    'ad_enabled_domains'            => { 'value' => $ad_enabled_domains, 'separator' => ', ' },
    'ad_servers'                    => { 'value' => $ad_servers, 'separator' => ', ', 'param_name' => 'ad_server' },
    'ad_backup_servers'             => { 'value' => $ad_backup_servers, 'separator' => ', ', 'param_name' => 'ad_backup_server' },
    'ad_access_filters'             => { 'value' => $ad_access_filters, 'separator' => '?', 'param_name' => 'ad_access_filter' },
    'ad_gpo_map_interactive'        => { 'value' => $ad_gpo_map_interactive, 'separator' => ', ' },
    'ad_gpo_map_remote_interactive' => { 'value' => $ad_gpo_map_remote_interactive, 'separator' => ', ' },
    'ad_gpo_map_network'            => { 'value' => $ad_gpo_map_network, 'separator' => ', ' },
    'ad_gpo_map_batch'              => { 'value' => $ad_gpo_map_batch, 'separator' => ', ' },
    'ad_gpo_map_service'            => { 'value' => $ad_gpo_map_service, 'separator' => ', ' },
    'ad_gpo_map_permit'             => { 'value' => $ad_gpo_map_permit, 'separator' => ', ' },
    'ad_gpo_map_deny'               => { 'value' => $ad_gpo_map_deny, 'separator' => ', ' },
  }

  # DynDNS parameters (only included if dyndns_update is true)
  $dyndns_params = {
    'dyndns_ttl'              => $dyndns_ttl,
    'dyndns_ifaces'           => $dyndns_ifaces, # Special case: array with param_name 'dyndns_iface'
    'dyndns_refresh_interval' => $dyndns_refresh_interval,
    'dyndns_update_ptr'       => $dyndns_update_ptr,
    'dyndns_force_tcp'        => $dyndns_force_tcp,
    'dyndns_server'           => $dyndns_server,
  }

  # Join all configuration lines
  $content = (['# sssd::provider::ad'] + $config_lines).join("\n")

  sssd::config::entry { "puppet_provider_${name}_ad":
    content => epp(
      "${module_name}/generic.epp",
      {
        'title'   => "domain/${title}",
        'content' => $content,
      },
    ),
  }
}
