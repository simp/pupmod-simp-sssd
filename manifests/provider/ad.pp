# Set up the 'ad' (Active Directory) id_provider section of a particular
# domain.
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
# @param ad_maximum_machine_account_password_age
# @param ad_machine_account_password_renewal_opts
# @param default_shell
# @param dyndns_update
# @param dyndns_ttl
#
# @param dyndns_ifaces
#   List of interfaces whose IP Addresses should be used for dynamic DNS
#   updates
#
#   * Has no effect if ``dyndns_update`` is not set
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
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::provider::ad (
  Optional[String]                                           $ad_domain                                = undef,
  Optional[Array[String]]                                    $ad_enabled_domains                       = undef,
  Optional[Array[Variant[Simplib::Hostname, Enum['_srv_']]]] $ad_servers                               = undef,
  Optional[Array[Simplib::Hostname]]                         $ad_backup_servers                        = undef,
  Optional[Simplib::Hostname]                                $ad_hostname                              = undef,
  Optional[Boolean]                                          $ad_enable_dns_sites                      = undef,
  Optional[Array[String]]                                    $ad_access_filters                        = undef,
  Optional[String]                                           $ad_site                                  = undef,
  Optional[Boolean]                                          $ad_enable_gc                             = undef,
  Optional[Enum['disabled','enforcing','permissive']]        $ad_gpo_access_control                    = undef,
  Optional[Integer[1]]                                       $ad_gpo_cache_timeout                     = undef,
  Optional[Array[String]]                                    $ad_gpo_map_interactive                   = undef,
  Optional[Array[String]]                                    $ad_gpo_map_remote_interactive            = undef,
  Optional[Array[String]]                                    $ad_gpo_map_network                       = undef,
  Optional[Array[String]]                                    $ad_gpo_map_batch                         = undef,
  Optional[Array[String]]                                    $ad_gpo_map_service                       = undef,
  Optional[Array[String]]                                    $ad_gpo_map_permit                        = undef,
  Optional[Array[String]]                                    $ad_gpo_map_deny                          = undef,
  Optional[Sssd::ADDefaultRight]                             $ad_gpo_default_right                     = undef,
  Optional[Integer[0]]                                       $ad_maximum_machine_account_password_age  = undef,
  Optional[Pattern['^\d+:\d+$']]                             $ad_machine_account_password_renewal_opts = undef,
  Optional[String]                                           $default_shell                            = undef,
  Optional[Boolean]                                          $dyndns_update                            = true,
  Optional[Integer]                                          $dyndns_ttl                               = undef,
  Optional[Array[String]]                                    $dyndns_ifaces                            = undef,
  Optional[Integer]                                          $dyndns_refresh_interval                  = undef,
  Optional[Boolean]                                          $dyndns_update_ptr                        = undef,
  Optional[Boolean]                                          $dyndns_force_tcp                         = undef,
  Optional[Simplib::Hostname]                                $dyndns_server                            = undef,
  Optional[String]                                           $override_homedir                         = undef,
  Optional[String]                                           $fallback_homedir                         = undef,
  Optional[Stdlib::Absolutepath]                             $homedir_substring                        = undef,
  Optional[String]                                           $krb5_realm                               = $ad_domain,
  Optional[Variant[Enum['none'],Stdlib::Absolutepath]]       $krb5_confd_path                          = undef,
  Optional[Boolean]                                          $krb5_use_enterprise_principal            = undef,
  Optional[Boolean]                                          $krb5_store_password_if_offline           = false,
  Boolean                                                    $ldap_id_mapping                          = true,
  Optional[String]                                           $ldap_schema                              = undef,
  Optional[Integer[0]]                                       $ldap_idmap_range_min                     = undef,
  Optional[Integer[1]]                                       $ldap_idmap_range_max                     = undef,
  Optional[Integer[1]]                                       $ldap_idmap_range_size                    = undef,
  Optional[String]                                           $ldap_idmap_default_domain_sid            = undef,
  Optional[String]                                           $ldap_idmap_default_domain                = undef,
  Optional[Boolean]                                          $ldap_idmap_autorid_compat                = undef,
  Optional[Integer[1]]                                       $ldap_idmap_helper_table_size             = undef
) {
  include '::sssd'

  concat::fragment { "sssd_${name}_ad_provider.domain":
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/provider/ad.erb"),
    order   => $name
  }
}
