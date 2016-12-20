# == Define: sssd::provider::ldap
#
# This define sets up the 'ldap' provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# See sssd-ldap.conf(5) for additional information.
#
# == Parameters
#
# [*name*]
#   The name of the associated domain section in the configuration file
#
# == Notes
#
# Regarding: POODLE - CVE-2014-3566
#
# The tls_cipher_suite variable is set to HIGH:-SSLv2 by default because
# OpenLDAP cannot set the SSL provider natively. By default, it will run TLSv1
# but cannot handle TLSv1.2 therefore the SSLv3 ciphers cannot be eliminated.
# Take care to ensure that your clients only connect with TLSv1 if possible.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define sssd::provider::ldap (
  $debug_level = '',
  $debug_timestamps = '',
  $debug_microseconds = '',
  Array[String]       $ldap_uri         = simplib::lookup('simp_options::ldap::uri',
                                            { 'default_value' => ["ldap://${hiera('simp_options::puppet::server')}"] } ),
  $ldap_backup_uri = [],
  $ldap_chpass_uri = [],
  $ldap_chpass_backup_uri = [],
  $ldap_chpass_update_last_change = true,
  String              $ldap_search_base     = simplib::lookup('simp_options::ldap::base_dn', { 'default_value' => '' }),
  String              $ldap_schema          = 'rfc2307',
  String              $ldap_default_bind_dn = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => "cn=hostAuth,ou=Hosts,%{hiera('simp_options::ldap::base_dn')}" }),
  $ldap_default_authtok_type = '',
  String              $ldap_default_authtok = simplib::lookup('simp_options::ldap::bind_hash',{ 'default_value' => '' }),
  String              $ldap_user_object_class = '',
  String              $ldap_user_name = '',
  String              $ldap_user_uid_number = '',
  String              $ldap_user_gid_number = '',
  String              $ldap_user_gecos = '',
  String              $ldap_user_home_directory = '',
  String              $ldap_user_shell = '',
  String              $ldap_user_uuid = '',
  String              $ldap_user_objectsid = '',
  String              $ldap_user_modify_timestamp = '',
  String              $ldap_user_shadow_last_change = '',
  String              $ldap_user_shadow_min = '',
  String              $ldap_user_shadow_max = '',
  String              $ldap_user_shadow_warning = '',
  String              $ldap_user_shadow_inactive = '',
  String              $ldap_user_shadow_expire = '',
  String              $ldap_user_krb_last_pwd_change = '',
  String              $ldap_user_krb_password_expiration = '',
  String              $ldap_user_ad_account_expires = '',
  String              $ldap_user_ad_user_account_control = '',
  String              $ldap_ns_account_lock = '',
  String              $ldap_user_nds_login_disabled = '',
  String              $ldap_user_nds_login_expiration_time = '',
  String              $ldap_user_nds_login_allowed_time_map = '',
  String              $ldap_user_principal = '',
  Array              $ldap_user_extra_attrs = [],
  String              $ldap_user_ssh_public_key = '',
  $ldap_force_upper_case_realm = '',
  $ldap_enumeration_refresh_timeout = '',
  $ldap_purge_cache_timeout = '',
  String              $ldap_user_fullname = '',
  String              $ldap_user_member_of = '',
  String              $ldap_user_authorized_service = '',
  String              $ldap_user_authorized_host = '',
  String              $ldap_group_object_class = '',
  String              $ldap_group_name = '',
  String              $ldap_group_gid_number = '',
  String              $ldap_group_member = '',
  String              $ldap_group_uuid = '',
  String              $ldap_group_objectsid = '',
  String              $ldap_group_modify_timestamp = '',
  $ldap_group_type = '',
  $ldap_group_nesting_level = '',
  $ldap_groups_use_matching_rule_in_chain = '',
  $ldap_initgroups_use_matching_rule_in_chain = '',
  $ldap_use_tokengroups = '',
  String              $ldap_netgroup_object_class = '',
  String              $ldap_netgroup_name = '',
  String              $ldap_netgroup_member = '',
  String              $ldap_netgroup_triple = '',
  String              $ldap_netgroup_uuid = '',
  String              $ldap_netgroup_modify_timestamp = '',
  String              $ldap_service_name = '',
  String              $ldap_service_port = '',
  String              $ldap_service_proto = '',
  String              $ldap_service_search_base = '',
  String              $ldap_search_timeout = '',
  $ldap_enumeration_search_timeout = '',
  $ldap_network_timeout = '',
  $ldap_opt_timeout = '',
  $ldap_connection_expire_timeout = '',
  $ldap_page_size = '',
  $ldap_disable_paging = '',
  $ldap_disable_range_retrieval = '',
  $ldap_sasl_minssf = '',
  $ldap_deref_threshold = '',
  String              $ldap_tls_reqcert = 'demand',
  Stdlib::Absolutepath   $app_pki_ca_dir         = "/etc/sssd/pki/cacerts",
  Stdlib::Absolutepath   $app_pki_key            = "/etc/sssd/pki/private/${::fqdn}.pem",
  Stdlib::Absolutepath   $app_pki_cert           = "/etc/sssd/pki/public/${::fqdn}.pub",
  Array[String]          $ldap_tls_cipher_suite  = simplib::lookup('simp_options::openssl::cipher_suite', { 'default_value' => ['HIGH','-SSLv2'] }),
  Boolean                $ldap_id_use_start_tls  = true,
  $ldap_id_mapping = '',
  $ldap_min_id = '',
  $ldap_max_id = '',
  String              $ldap_sasl_mech = '',
  String              $ldap_sasl_authid = '',
  String              $ldap_sasl_realm = '',
  $ldap_sasl_canonicalize = '',
  $ldap_krb5_keytab = '',
  $ldap_krb5_init_creds = '',
  $ldap_krb5_ticket_lifetime = '',
  $krb5_server = [],
  $krb5_backup_server = [],
  $krb5_realm = '',
  $krb5_canonicalize = '',
  $krb5_use_kdcinfo = '',
  String              $ldap_pwd_policy = 'shadow',
  $ldap_referrals = '',
  String              $ldap_dns_service_name = '',
  $ldap_chpass_dns_service_name = '',
  String              $ldap_access_filter = '',
  String              $ldap_account_expire_policy = 'shadow',
  $ldap_access_order = ['expire','lockout'],
  $ldap_pwdlockout_dn = '',
  $ldap_deref = '',
  String              $ldap_sudorule_object_class = '',
String                $ldap_sudorule_name = '',
  String              $ldap_sudorule_command = '',
  String              $ldap_sudorule_host = '',
  String              $ldap_sudorule_user = '',
  String              $ldap_sudorule_option = '',
  String              $ldap_sudorule_runasuser = '',
  String              $ldap_sudorule_runasgroup = '',
  String              $ldap_sudorule_notbefore = '',
  String              $ldap_sudorule_notafter = '',
  String              $ldap_sudorule_order = '',
  $ldap_sudo_full_refresh_interval = '',
  $ldap_sudo_smart_refresh_interval = '',
  $ldap_sudo_use_host_filter = '',
  $ldap_sudo_hostnames = [],
  $ldap_sudo_ip = [],
  $ldap_sudo_include_netgroups  = '',
  $ldap_sudo_include_regexp = '',
  String              $ldap_autofs_map_master_name = '',
  String              $ldap_autofs_map_object_class = '',
  String              $ldap_autofs_map_name = '',
  String              $ldap_autofs_entry_object_class = '',
  String              $ldap_autofs_entry_key = '',
  String              $ldap_autofs_entry_value = '',
# Be careful with the following options!
  String              $ldap_netgroup_search_base = '',
  String              $ldap_user_search_base = '',
  String              $ldap_group_search_base = '',
  String              $ldap_sudo_search_base = '',
  String              $ldap_autofs_search_base = '',
# Advanced Configuration - Read the man page
  $ldap_idmap_range_min = '',
  $ldap_idmap_range_max = '',
  $ldap_idmap_range_size = '',
  String              $ldap_idmap_default_domain_sid = '',
  String              $ldap_idmap_default_domain = '',
  $ldap_idmap_autorid_compat = ''
) {
#  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
#  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
#  validate_array($ldap_uri)
#  unless empty($ldap_backup_uri) { validate_uri_list($ldap_backup_uri) }
#  validate_uri_list($ldap_chpass_uri)
#  unless empty($ldap_chpass_backup_uri) { validate_uri_list($ldap_chpass_backup_uri) }
#  validate_array_member($ldap_schema,['rfc2307','rfc2307bis','IPA','AD'])
#  unless empty($ldap_default_authtok_type) { validate_array_member($ldap_default_authtok_type,['password','obfuscated_password']) }
#  validate_array($ldap_user_extra_attrs)
#  unless empty($ldap_force_upper_case_realm) { validate_bool($ldap_force_upper_case_realm) }
#  unless empty($ldap_enumeration_refresh_timeout) { validate_integer($ldap_enumeration_refresh_timeout) }
#  unless empty($ldap_purge_cache_timeout) { validate_integer($ldap_purge_cache_timeout) }
#  unless empty($ldap_group_type) { validate_integer($ldap_group_type) }
#  unless empty($ldap_group_nesting_level) { validate_integer($ldap_group_nesting_level) }
#  unless empty($ldap_groups_use_matching_rule_in_chain) { validate_bool($ldap_groups_use_matching_rule_in_chain) }
#  unless empty($ldap_initgroups_use_matching_rule_in_chain) { validate_bool($ldap_initgroups_use_matching_rule_in_chain) }
#  unless empty($ldap_use_tokengroups) { validate_bool($ldap_use_tokengroups) }
#  unless empty($ldap_search_timeout) { validate_integer($ldap_search_timeout) }
#  unless empty($ldap_enumeration_search_timeout) { validate_integer($ldap_enumeration_search_timeout) }
#  unless empty($ldap_network_timeout) { validate_integer($ldap_network_timeout) }
#  unless empty($ldap_opt_timeout) { validate_integer($ldap_opt_timeout) }
#  unless empty($ldap_page_size) { validate_integer($ldap_page_size) }
#  unless empty($ldap_disable_paging) { validate_bool($ldap_disable_paging) }
#  unless empty($ldap_disable_range_retrieval) { validate_bool($ldap_disable_range_retrieval) }
#  unless empty($ldap_sasl_minssf) { validate_integer($ldap_sasl_minssf) }
#  unless empty($ldap_deref_threshold) { validate_integer($ldap_deref_threshold) }
#  validate_array_member($ldap_tls_reqcert,['never','allow','try','demand','hard'])
#  unless empty($ldap_id_mapping) { validate_bool($ldap_id_mapping) }
#  unless empty($ldap_min_id) { validate_integer($ldap_min_id) }
#  unless empty($ldap_max_id) { validate_integer($ldap_max_id) }
#  unless empty($ldap_sasl_canonicalize) { validate_bool($ldap_sasl_canonicalize) }
#  unless empty($ldap_krb5_keytab) { validate_absolute_path($ldap_krb5_keytab) }
#  unless empty($ldap_krb5_init_creds) { validate_bool($ldap_krb5_init_creds) }
#  unless empty($ldap_krb5_ticket_lifetime) { validate_bool($ldap_krb5_ticket_lifetime) }
#  unless empty($krb5_server) { validate_net_list($krb5_server) }
#  unless empty($krb5_backup_server) { validate_net_list($krb5_backup_server) }
#  unless empty($krb5_canonicalize) { validate_bool($krb5_canonicalize) }
#  unless empty($krb5_use_kdcinfo) { validate_bool($krb5_use_kdcinfo) }
#  validate_array_member($ldap_pwd_policy,['none','shadow','mit_kerberos'])
#  unless empty($ldap_referrals) { validate_bool($ldap_referrals) }
#  validate_bool($ldap_chpass_update_last_change)
#  validate_array_member($ldap_account_expire_policy,['shadow','ad','rhds','ipa','e89ds','nds'])
#  validate_array($ldap_access_order)
#  validate_array_member($ldap_access_order,['filter','lockout','expire','authorized_service','host'])
#  unless empty($ldap_deref) { validate_array_member($ldap_deref,['never','searching','finding','always']) }
#  unless empty($ldap_sudo_full_refresh_interval){ validate_integer($ldap_sudo_full_refresh_interval) }
#  unless empty($ldap_sudo_smart_refresh_interval){ validate_integer($ldap_sudo_smart_refresh_interval) }
#  unless empty($ldap_sudo_use_host_filter){ validate_bool($ldap_sudo_use_host_filter) }
#  validate_array($ldap_sudo_hostnames)
#  validate_net_list($ldap_sudo_hostnames)
#  validate_array($ldap_sudo_ip)
#  validate_net_list($ldap_sudo_ip)
#  unless empty($ldap_sudo_include_netgroups){ validate_bool($ldap_sudo_include_netgroups) }
#  unless empty($ldap_sudo_include_regexp){ validate_bool($ldap_sudo_include_regexp) }
#  unless empty($ldap_idmap_range_min){ validate_integer($ldap_idmap_range_min) }
#  unless empty($ldap_idmap_range_max){ validate_integer($ldap_idmap_range_max) }
#  unless empty($ldap_idmap_range_size){ validate_integer($ldap_idmap_range_size) }
#  unless empty($ldap_idmap_autorid_compat){ validate_bool($ldap_idmap_autorid_compat) }

  include '::sssd'
  
 $ldap_tls_cacertdir = $app_pki_cert_dir

 $ldap_tls_cert = $app_pki_cert

 $ldap_tls_key = $app_pki_key

  simpcat_fragment { "sssd+${name}#ldap_provider.domain":
    content => template('sssd/provider/ldap.erb')
  }
}
