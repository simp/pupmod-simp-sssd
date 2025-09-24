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
  sssd::config::entry { "puppet_provider_${name}_ad":
    content => epp(
      "${module_name}/provider/ad.epp",
      {
        'title'                                    => $title,
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
        'dyndns_update'                            => $dyndns_update,
        'dyndns_ttl'                               => $dyndns_ttl,
        'dyndns_ifaces'                            => $dyndns_ifaces,
        'dyndns_refresh_interval'                  => $dyndns_refresh_interval,
        'dyndns_update_ptr'                        => $dyndns_update_ptr,
        'dyndns_force_tcp'                         => $dyndns_force_tcp,
        'dyndns_server'                            => $dyndns_server,
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
    ),
  }
}
