# Define: sssd::provider::ldap
#
# This define sets up the 'ldap' provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# Configuration notes:
#
# * See sssd-ldap.conf(5) for additional information.
# * Be careful with the following configuration:
#     * ldap_netgroup_search_base
#     * ldap_user_search_base
#     * ldap_group_search_base
#     * ldap_sudo_search_base
#     * ldap_autofs_search_base
#
# * Be sure to read the man page for the following advanced
#   configuration:
#     * ldap_idmap_range_min
#     * ldap_idmap_range_max
#     * ldap_idmap_range_size
#     * ldap_idmap_default_domain_sid
#     * ldap_idmap_default_domain
#     * ldap_idmap_autorid_compat
#
#
# Regarding: POODLE - CVE-2014-3566
#
# The tls_cipher_suite variable is set to HIGH:-SSLv2 by default because
# OpenLDAP cannot set the SSL provider natively. By default, it will run TLSv1
# but cannot handle TLSv1.2 therefore the SSLv3 ciphers cannot be eliminated.
# Take care to ensure that your clients only connect with TLSv1 if possible.
#
# @param name
#   The name of the associated domain section in the configuration file
#
# @param strip_128_bit_ciphers
#   If set, on EL6 systems, all 128 bit ciphers will be removed from
#   ``tls_cipher_suite`` prior to being written to the system.
#
#   This is due to a bug in the LDAP client libraries that will drop the SSF
#   level to 128 when connecting over StartTLS which will be rejected by the
#   standard SIMP LDAP implementation.
#
#   This has no effect on EL7+ systems.
#
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param ldap_uri
# @param ldap_backup_uri
# @param ldap_chpass_uri
# @param ldap_chpass_backup_uri
# @param ldap_chpass_update_last_change
# @param ldap_search_base
# @param ldap_schema
# @param ldap_default_bind_dn
# @param ldap_default_authtok_type
# @param ldap_default_authtok
# @param ldap_user_object_class
# @param ldap_user_name
# @param ldap_user_uid_number
# @param ldap_user_gid_number
# @param ldap_user_gecos
# @param ldap_user_home_directory
# @param ldap_user_shell
# @param ldap_user_uuid
# @param ldap_user_objectsid
# @param ldap_user_modify_timestamp
# @param ldap_user_shadow_last_change
# @param ldap_user_shadow_min
# @param ldap_user_shadow_max
# @param ldap_user_shadow_warning
# @param ldap_user_shadow_inactive
# @param ldap_user_shadow_expire
# @param ldap_user_krb_last_pwd_change
# @param ldap_user_krb_password_expiration
# @param ldap_user_ad_account_expires
# @param ldap_user_ad_user_account_control
# @param ldap_ns_account_lock
# @param ldap_user_nds_login_disabled
# @param ldap_user_nds_login_expiration_time
# @param ldap_user_nds_login_allowed_time_map
# @param ldap_user_principal
# @param ldap_user_extra_attrs
# @param ldap_user_ssh_public_key
# @param ldap_force_upper_case_realm
# @param ldap_enumeration_refresh_timeout
# @param ldap_purge_cache_timeout
# @param ldap_user_fullname
# @param ldap_user_member_of
# @param ldap_user_authorized_service
# @param ldap_user_authorized_host
# @param ldap_group_object_class
# @param ldap_group_name
# @param ldap_group_gid_number
# @param ldap_group_member
# @param ldap_group_uuid
# @param ldap_group_objectsid
# @param ldap_group_modify_timestamp
# @param ldap_group_type
# @param ldap_group_nesting_level
# @param ldap_groups_use_matching_rule_in_chain
# @param ldap_initgroups_use_matching_rule_in_chain
# @param ldap_use_tokengroups
# @param ldap_netgroup_object_class
# @param ldap_netgroup_name
# @param ldap_netgroup_member
# @param ldap_netgroup_triple
# @param ldap_netgroup_uuid
# @param ldap_netgroup_modify_timestamp
# @param ldap_service_name
# @param ldap_service_port
# @param ldap_service_proto
# @param ldap_service_search_base
# @param ldap_search_timeout
# @param ldap_enumeration_search_timeout
# @param ldap_network_timeout
# @param ldap_opt_timeout
# @param ldap_connection_expire_timeout
# @param ldap_page_size
# @param ldap_disable_paging
# @param ldap_disable_range_retrieval
# @param ldap_sasl_minssf
# @param ldap_deref_threshold
# @param ldap_tls_reqcert
# @param ldap_tls_cacert
# @param app_pki_ca_dir
# @param app_pki_key
# @param app_pki_cert
# @param strip_128_bit_ciphers
# @param ldap_tls_cipher_suite
# @param ldap_id_use_start_tls
# @param ldap_id_mapping
# @param ldap_min_id
# @param ldap_max_id
# @param ldap_sasl_mech
# @param ldap_sasl_authid
# @param ldap_sasl_realm
# @param ldap_sasl_canonicalize
# @param ldap_krb5_keytab
# @param ldap_krb5_init_creds
# @param ldap_krb5_ticket_lifetime
# @param krb5_server
# @param krb5_backup_server
# @param krb5_realm
# @param krb5_canonicalize
# @param krb5_use_kdcinfo
# @param ldap_pwd_policy
# @param ldap_referrals
# @param ldap_dns_service_name
# @param ldap_chpass_dns_service_name
# @param ldap_access_filter
# @param ldap_account_expire_policy
#   Set this to '' when you want to omit this configuration
#   in order to use the system default.
#
# @param ldap_access_order
# @param ldap_pwdlockout_dn
# @param ldap_deref
# @param ldap_sudorule_object_class
# @param ldap_sudorule_name
# @param ldap_sudorule_command
# @param ldap_sudorule_host
# @param ldap_sudorule_user
# @param ldap_sudorule_option
# @param ldap_sudorule_runasuser
# @param ldap_sudorule_runasgroup
# @param ldap_sudorule_notbefore
# @param ldap_sudorule_notafter
# @param ldap_sudorule_order
# @param ldap_sudo_full_refresh_interval
# @param ldap_sudo_smart_refresh_interval
# @param ldap_sudo_use_host_filter
# @param ldap_sudo_hostnames
# @param ldap_sudo_ip
# @param ldap_sudo_include_netgroups
# @param ldap_sudo_include_regexp
# @param ldap_autofs_map_master_name
# @param ldap_autofs_map_object_class
# @param ldap_autofs_map_name
# @param ldap_autofs_entry_object_class
# @param ldap_autofs_entry_key
# @param ldap_autofs_entry_value
# @param ldap_netgroup_search_base
# @param ldap_user_search_base
# @param ldap_group_search_base
# @param ldap_sudo_search_base
# @param ldap_autofs_search_base
#
# Advanced Configuration - Read the man page
#
# @param ldap_idmap_range_min
# @param ldap_idmap_range_max
# @param ldap_idmap_range_size
# @param ldap_idmap_default_domain_sid
# @param ldap_idmap_default_domain
# @param ldap_idmap_autorid_compat
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::provider::ldap (
  Optional[Sssd::DebugLevel]            $debug_level                       = undef,
  Optional[Boolean]                     $debug_timestamps                  = undef,
  Boolean                               $debug_microseconds                = false,
  Array[Simplib::URI,1]                 $ldap_uri                          = simplib::lookup('simp_options::ldap::uri', { 'default_value' => undef }),
  Optional[Array[Simplib::URI,1]]       $ldap_backup_uri                   = undef,
  Optional[Array[Simplib::URI,1]]       $ldap_chpass_uri                   = undef,
  Optional[Array[Simplib::URI,1]]       $ldap_chpass_backup_uri            = undef,
  Boolean                               $ldap_chpass_update_last_change    = true,
  String                                $ldap_search_base                  = simplib::lookup('simp_options::ldap::base_dn', { 'default_value' => undef }),
  Sssd::LdapSchema                      $ldap_schema                       = 'rfc2307',
  String                                $ldap_default_bind_dn              = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => undef }),
  Optional[Sssd::LdapDefaultAuthtok]    $ldap_default_authtok_type         = undef,
  Optional[String]                      $ldap_default_authtok              = simplib::lookup('simp_options::ldap::bind_pw', { 'default_value' => undef }),
  Optional[String]                      $ldap_user_object_class            = undef,
  Optional[String]                      $ldap_user_name                    = undef,
  Optional[String]                      $ldap_user_uid_number              = undef,
  Optional[String]                      $ldap_user_gid_number              = undef,
  Optional[String]                      $ldap_user_gecos                   = undef,
  Optional[String]                      $ldap_user_home_directory          = undef,
  Optional[String]                      $ldap_user_shell                   = undef,
  Optional[String]                      $ldap_user_uuid                    = undef,
  Optional[String]                      $ldap_user_objectsid               = undef,
  Optional[String]                      $ldap_user_modify_timestamp        = undef,
  Optional[String]                      $ldap_user_shadow_last_change      = undef,
  Optional[String]                      $ldap_user_shadow_min              = undef,
  Optional[String]                      $ldap_user_shadow_max              = undef,
  Optional[String]                      $ldap_user_shadow_warning          = undef,
  Optional[String]                      $ldap_user_shadow_inactive         = undef,
  Optional[String]                      $ldap_user_shadow_expire           = undef,
  Optional[String]                      $ldap_user_krb_last_pwd_change     = undef,
  Optional[String]                      $ldap_user_krb_password_expiration = undef,
  Optional[String]                      $ldap_user_ad_account_expires      = undef,
  Optional[String]                      $ldap_user_ad_user_account_control = undef,
  Optional[String]                      $ldap_ns_account_lock              = undef,
  Optional[String]                      $ldap_user_nds_login_disabled      = undef,
  Optional[String]                      $ldap_user_nds_login_expiration_time = undef,
  Optional[String]                      $ldap_user_nds_login_allowed_time_map = undef,
  Optional[String]                      $ldap_user_principal               = undef,
  Optional[Array[String,1]]             $ldap_user_extra_attrs             = undef,
  Optional[String]                      $ldap_user_ssh_public_key          = undef,
  Boolean                               $ldap_force_upper_case_realm       = false,
  Optional[Integer[0]]                  $ldap_enumeration_refresh_timeout  = undef,
  Optional[Integer[0]]                  $ldap_purge_cache_timeout          = undef,
  Optional[String]                      $ldap_user_fullname                = undef,
  Optional[String]                      $ldap_user_member_of               = undef,
  Optional[String]                      $ldap_user_authorized_service      = undef,
  Optional[String]                      $ldap_user_authorized_host         = undef,
  Optional[String]                      $ldap_group_object_class           = undef,
  Optional[String]                      $ldap_group_name                   = undef,
  Optional[String]                      $ldap_group_gid_number             = undef,
  Optional[String]                      $ldap_group_member                 = undef,
  Optional[String]                      $ldap_group_uuid                   = undef,
  Optional[String]                      $ldap_group_objectsid              = undef,
  Optional[String]                      $ldap_group_modify_timestamp       = undef,
  Optional[Integer]                     $ldap_group_type                   = undef,
  Optional[Integer]                     $ldap_group_nesting_level          = undef,
  Boolean                               $ldap_groups_use_matching_rule_in_chain = false,
  Boolean                               $ldap_initgroups_use_matching_rule_in_chain = false,
  Boolean                               $ldap_use_tokengroups              = false,
  Optional[String]                      $ldap_netgroup_object_class        = undef,
  Optional[String]                      $ldap_netgroup_name                = undef,
  Optional[String]                      $ldap_netgroup_member              = undef,
  Optional[String]                      $ldap_netgroup_triple              = undef,
  Optional[String]                      $ldap_netgroup_uuid                = undef,
  Optional[String]                      $ldap_netgroup_modify_timestamp    = undef,
  Optional[String]                      $ldap_service_name                 = undef,
  Optional[String]                      $ldap_service_port                 = undef,
  Optional[String]                      $ldap_service_proto                = undef,
  Optional[String]                      $ldap_service_search_base          = undef,
  Optional[Integer[0]]                  $ldap_search_timeout               = undef,
  Optional[Integer[0]]                  $ldap_enumeration_search_timeout   = undef,
  Optional[Integer[0]]                  $ldap_network_timeout              = undef,
  Optional[Integer[0]]                  $ldap_opt_timeout                  = undef,
  Optional[Integer[0]]                  $ldap_connection_expire_timeout    = undef,
  Optional[Integer[0]]                  $ldap_page_size                    = undef,
  Boolean                               $ldap_disable_paging               = false,
  Boolean                               $ldap_disable_range_retrieval      = false,
  Optional[Integer]                     $ldap_sasl_minssf                  = undef,
  Optional[Integer[0]]                  $ldap_deref_threshold              = undef,
  Sssd::LdapTlsReqcert                  $ldap_tls_reqcert                  = 'demand',
  Optional[String]                      $ldap_tls_cacert                   = undef,
  Optional[Stdlib::Absolutepath]        $app_pki_ca_dir                    = undef,
  Optional[Stdlib::Absolutepath]        $app_pki_key                       = undef,
  Optional[Stdlib::Absolutepath]        $app_pki_cert                      = undef,
  Boolean                               $strip_128_bit_ciphers             = true,
  Array[String]                         $ldap_tls_cipher_suite             = ['HIGH','-SSLv2'],
  Boolean                               $ldap_id_use_start_tls             = true,
  Boolean                               $ldap_id_mapping                   = false,
  Optional[Integer[0]]                  $ldap_min_id                       = undef,
  Optional[Integer[0]]                  $ldap_max_id                       = undef,
  Optional[String]                      $ldap_sasl_mech                    = undef,
  Optional[String]                      $ldap_sasl_authid                  = undef,
  Optional[String]                      $ldap_sasl_realm                   = undef,
  Boolean                               $ldap_sasl_canonicalize            = false,
  Optional[Stdlib::Absolutepath]        $ldap_krb5_keytab                  = undef,
  Boolean                               $ldap_krb5_init_creds              = true,
  Optional[Integer]                     $ldap_krb5_ticket_lifetime         = undef,
  Optional[Array[String,1]]             $krb5_server                       = undef,
  Optional[Array[String,1]]             $krb5_backup_server                = undef,
  Optional[String]                      $krb5_realm                        = undef,
  Boolean                               $krb5_canonicalize                 = false,
  Boolean                               $krb5_use_kdcinfo                  = true,
  Enum['none','shadow','mit_kerberos']  $ldap_pwd_policy                   = 'shadow',
  Boolean                               $ldap_referrals                    = true,
  Optional[String]                      $ldap_dns_service_name             = undef,
  Optional[String]                      $ldap_chpass_dns_service_name      = undef,
  Optional[String]                      $ldap_access_filter                = undef,
  Sssd::LdapAccountExpirePol            $ldap_account_expire_policy        = 'shadow',
  Sssd::LdapAccessOrder                 $ldap_access_order                 = ['expire','lockout'],
  Optional[String]                      $ldap_pwdlockout_dn                = undef,
  Optional[Sssd::LdapDeref]             $ldap_deref                        = undef,
  Optional[String]                      $ldap_sudorule_object_class        = undef,
  Optional[String]                      $ldap_sudorule_name                = undef,
  Optional[String]                      $ldap_sudorule_command             = undef,
  Optional[String]                      $ldap_sudorule_host                = undef,
  Optional[String]                      $ldap_sudorule_user                = undef,
  Optional[String]                      $ldap_sudorule_option              = undef,
  Optional[String]                      $ldap_sudorule_runasuser           = undef,
  Optional[String]                      $ldap_sudorule_runasgroup          = undef,
  Optional[String]                      $ldap_sudorule_notbefore           = undef,
  Optional[String]                      $ldap_sudorule_notafter            = undef,
  Optional[String]                      $ldap_sudorule_order               = undef,
  Optional[Integer[0]]                  $ldap_sudo_full_refresh_interval   = undef,
  Optional[Integer[0]]                  $ldap_sudo_smart_refresh_interval  = undef,
  Boolean                               $ldap_sudo_use_host_filter         = true,
  Optional[Array[String,1]]             $ldap_sudo_hostnames               = undef,
  Optional[Array[String,1]]             $ldap_sudo_ip                      = undef,
  Boolean                               $ldap_sudo_include_netgroups       = true,
  Boolean                               $ldap_sudo_include_regexp          = true,
  Optional[String]                      $ldap_autofs_map_master_name       = undef,
  Optional[String]                      $ldap_autofs_map_object_class      = undef,
  Optional[String]                      $ldap_autofs_map_name              = undef,
  Optional[String]                      $ldap_autofs_entry_object_class    = undef,
  Optional[String]                      $ldap_autofs_entry_key             = undef,
  Optional[String]                      $ldap_autofs_entry_value           = undef,
# Be careful with the following options!
  Optional[String]                      $ldap_netgroup_search_base         = undef,
  Optional[String]                      $ldap_user_search_base             = undef,
  Optional[String]                      $ldap_group_search_base            = undef,
  Optional[String]                      $ldap_sudo_search_base             = undef,
  Optional[String]                      $ldap_autofs_search_base           = undef,
# Advanced Configuration - Read the man page
  Optional[Integer[0]]                  $ldap_idmap_range_min              = undef,
  Optional[Integer[0]]                  $ldap_idmap_range_max              = undef,
  Optional[Integer[0]]                  $ldap_idmap_range_size             = undef,
  Optional[String]                      $ldap_idmap_default_domain_sid     = undef,
  Optional[String]                      $ldap_idmap_default_domain         = undef,
  Boolean                               $ldap_idmap_autorid_compat         = false
) {
  include '::sssd'

  if $strip_128_bit_ciphers {
    # This is here due to a bug in the LDAP client library on EL6 that will set
    # the SSF to 128 when connecting over StartTLS if there are *any* 128-bit
    # ciphers in the list.
    if $facts['os']['name'] in ['RedHat','CentOS'] and (versioncmp($facts['os']['release']['major'],'7') < 0) {
      $_ldap_tls_cipher_suite = $ldap_tls_cipher_suite + ['-AES128']
    }
    else {
      $_ldap_tls_cipher_suite = $ldap_tls_cipher_suite
    }
  }
  else {
    $_ldap_tls_cipher_suite = $ldap_tls_cipher_suite
  }

  if empty($ldap_account_expire_policy) {
    $_ldap_account_expire_policy = undef
  }
  else {
    $_ldap_account_expire_policy = $ldap_account_expire_policy
  }

  if $app_pki_ca_dir {
    $ldap_tls_cacertdir = $app_pki_ca_dir
  } else {
    $ldap_tls_cacertdir = "${sssd::app_pki_dir}/cacerts"
  }

  if $app_pki_key {
    $ldap_tls_key = $app_pki_key
  } else {
    $ldap_tls_key = "${sssd::app_pki_dir}/private/${::fqdn}.pem"
  }

  if $app_pki_cert {
    $ldap_tls_cert = $app_pki_cert
  } else {
    $ldap_tls_cert = "${sssd::app_pki_dir}/public/${::fqdn}.pub"
  }

  concat::fragment { "sssd_${name}_ldap_provider.domain":
    target  => '/etc/sssd/sssd.conf',
    content => template('sssd/provider/ldap.erb'),
    order   => $name
  }
}
