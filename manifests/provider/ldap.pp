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
  $ldap_uri = hiera('ldap::uri'),
  $ldap_backup_uri = [],
  $ldap_chpass_uri = [],
  $ldap_chpass_backup_uri = [],
  $ldap_chpass_updates_last_change = true,
  $ldap_search_base = hiera('ldap::base_dn'),
  $ldap_schema = 'rfc2307',
  $ldap_default_bind_dn = hiera('ldap::bind_dn'),
  $ldap_default_authtok_type = '',
  $ldap_default_authtok = hiera('ldap::bind_pw',''),
  $ldap_user_object_class = '',
  $ldap_user_name = '',
  $ldap_user_uid_number = '',
  $ldap_user_gid_number = '',
  $ldap_user_gecos = '',
  $ldap_user_home_directory = '',
  $ldap_user_shell = '',
  $ldap_user_uuid = '',
  $ldap_user_objectsid = '',
  $ldap_user_modify_timestamp = '',
  $ldap_user_shadow_last_change = '',
  $ldap_user_shadow_min = '',
  $ldap_user_shadow_max = '',
  $ldap_user_shadow_warning = '',
  $ldap_user_shadow_inactive = '',
  $ldap_user_shadow_expire = '',
  $ldap_user_krb_last_pwd_change = '',
  $ldap_user_krb_password_expiration = '',
  $ldap_user_ad_account_expires = '',
  $ldap_user_ad_user_account_control = '',
  $ldap_ns_account_lock = '',
  $ldap_user_nds_login_disabled = '',
  $ldap_user_nds_login_expiration_time = '',
  $ldap_user_nds_login_allowed_time_map = '',
  $ldap_user_principal = '',
  $ldap_user_extra_attrs = [],
  $ldap_user_ssh_public_key = '',
  $ldap_force_upper_case_realm = '',
  $ldap_enumeration_refresh_timeout = '',
  $ldap_purge_cache_timeout = '',
  $ldap_user_fullname = '',
  $ldap_user_member_of = '',
  $ldap_user_authorized_service = '',
  $ldap_user_authorized_host = '',
  $ldap_group_object_class = '',
  $ldap_group_name = '',
  $ldap_group_gid_number = '',
  $ldap_group_member = '',
  $ldap_group_uuid = '',
  $ldap_group_objectsid = '',
  $ldap_group_modify_timestamp = '',
  $ldap_group_type = '',
  $ldap_group_nesting_level = '',
  $ldap_groups_use_matching_rule_in_chain = '',
  $ldap_initgroups_use_matching_rule_in_chain = '',
  $ldap_use_tokengroups = '',
  $ldap_netgroup_object_class = '',
  $ldap_netgroup_name = '',
  $ldap_netgroup_member = '',
  $ldap_netgroup_triple = '',
  $ldap_netgroup_uuid = '',
  $ldap_netgroup_modify_timestamp = '',
  $ldap_service_name = '',
  $ldap_service_port = '',
  $ldap_service_proto = '',
  $ldap_service_search_base = '',
  $ldap_search_timeout = '',
  $ldap_enumeration_search_timeout = '',
  $ldap_network_timeout = '',
  $ldap_opt_timeout = '',
  $ldap_connection_expire_timeout = '',
  $ldap_page_size = '',
  $ldap_disable_paging = '',
  $ldap_disable_range_retrieval = '',
  $ldap_sasl_minssf = '',
  $ldap_deref_threshold = '',
  $ldap_tls_reqcert = 'demand',
  $ldap_tls_cacert = '',
  $ldap_tls_cacertdir = '',
  $ldap_tls_cert = '',
  $ldap_tls_key = '',
  $ldap_tls_cipher_suite = hiera('openssl::cipher_suite',[
    'HIGH',
    '-SSLv2'
  ]),
  $ldap_id_use_start_tls = true,
  $ldap_id_mapping = '',
  $ldap_min_id = '',
  $ldap_max_id = '',
  $ldap_sasl_mech = '',
  $ldap_sasl_authid = '',
  $ldap_sasl_realm = '',
  $ldap_sasl_canonicalize = '',
  $ldap_krb5_keytab = '',
  $ldap_krb5_init_creds = '',
  $ldap_krb5_ticket_lifetime = '',
  $krb5_server = [],
  $krb5_backup_server = [],
  $krb5_realm = '',
  $krb5_canonicalize = '',
  $krb5_use_kdcinfo = '',
  $ldap_pwd_policy = 'shadow',
  $ldap_referrals = '',
  $ldap_dns_service_name = '',
  $ldap_chpass_dns_service_name = '',
  $ldap_chpass_update_last_change = '',
  $ldap_access_filter = '',
  $ldap_account_expire_policy = 'shadow',
  $ldap_access_order = ['expire','lockout'],
  $ldap_pwdlockout_dn = '',
  $ldap_deref = '',
  $ldap_sudorule_object_class = '',
  $ldap_sudorule_name = '',
  $ldap_sudorule_command = '',
  $ldap_sudorule_host = '',
  $ldap_sudorule_user = '',
  $ldap_sudorule_option = '',
  $ldap_sudorule_runasuser = '',
  $ldap_sudorule_runasgroup = '',
  $ldap_sudorule_notbefore = '',
  $ldap_sudorule_notafter = '',
  $ldap_sudorule_order = '',
  $ldap_sudo_full_refresh_interval = '',
  $ldap_sudo_smart_refresh_interval = '',
  $ldap_sudo_use_host_filter = '',
  $ldap_sudo_hostnames = [],
  $ldap_sudo_ip = [],
  $ldap_sudo_include_netgroups  = '',
  $ldap_sudo_include_regexp = '',
  $ldap_autofs_map_master_name = '',
  $ldap_autofs_map_object_class = '',
  $ldap_autofs_map_name = '',
  $ldap_autofs_entry_object_class = '',
  $ldap_autofs_entry_key = '',
  $ldap_autofs_entry_value = '',
# Be careful with the following options!
  $ldap_netgroup_search_base = '',
  $ldap_user_search_base = '',
  $ldap_group_search_base = '',
  $ldap_sudo_search_base = '',
  $ldap_autofs_search_base = '',
# Advanced Configuration - Read the man page
  $ldap_idmap_range_min = '',
  $ldap_idmap_range_max = '',
  $ldap_idmap_range_size = '',
  $ldap_idmap_default_domain_sid = '',
  $ldap_idmap_default_domain = '',
  $ldap_idmap_autorid_compat = ''
) {
  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
  validate_array($ldap_uri)
  validate_uri_list($ldap_uri)
  unless empty($ldap_backup_uri) { validate_uri_list($ldap_backup_uri) }
  validate_uri_list($ldap_chpass_uri)
  unless empty($ldap_chpass_backup_uri) { validate_uri_list($ldap_chpass_backup_uri) }
  validate_bool($ldap_chpass_updates_last_change)
  validate_string($ldap_search_base)
  validate_string($ldap_schema)
  validate_array_member($ldap_schema,['rfc2307','rfc2307bis','IPA','AD'])
  validate_string($ldap_default_bind_dn)
  validate_string($ldap_default_authtok_type)
  unless empty($ldap_default_authtok_type) { validate_array_member($ldap_default_authtok_type,['password','obfuscated_password']) }
  validate_string($ldap_default_authtok)
  validate_string($ldap_user_object_class)
  validate_string($ldap_user_name)
  validate_string($ldap_user_uid_number)
  validate_string($ldap_user_gid_number)
  validate_string($ldap_user_gecos)
  validate_string($ldap_user_home_directory)
  validate_string($ldap_user_shell)
  validate_string($ldap_user_uuid)
  validate_string($ldap_user_objectsid)
  validate_string($ldap_user_modify_timestamp)
  validate_string($ldap_user_shadow_last_change)
  validate_string($ldap_user_shadow_min)
  validate_string($ldap_user_shadow_max)
  validate_string($ldap_user_shadow_warning)
  validate_string($ldap_user_shadow_inactive)
  validate_string($ldap_user_shadow_expire)
  validate_string($ldap_user_krb_last_pwd_change)
  validate_string($ldap_user_krb_password_expiration)
  validate_string($ldap_user_ad_account_expires)
  validate_string($ldap_user_ad_user_account_control)
  validate_string($ldap_ns_account_lock)
  validate_string($ldap_user_nds_login_disabled)
  validate_string($ldap_user_nds_login_expiration_time)
  validate_string($ldap_user_nds_login_allowed_time_map)
  validate_string($ldap_user_principal)
  validate_array($ldap_user_extra_attrs)
  validate_string($ldap_user_ssh_public_key)
  unless empty($ldap_force_upper_case_realm) { validate_bool($ldap_force_upper_case_realm) }
  unless empty($ldap_enumeration_refresh_timeout) { validate_integer($ldap_enumeration_refresh_timeout) }
  unless empty($ldap_purge_cache_timeout) { validate_integer($ldap_purge_cache_timeout) }
  validate_string($ldap_user_fullname)
  validate_string($ldap_user_member_of)
  validate_string($ldap_user_authorized_service)
  validate_string($ldap_user_authorized_host)
  validate_string($ldap_group_object_class)
  validate_string($ldap_group_name)
  validate_string($ldap_group_gid_number)
  validate_string($ldap_group_member)
  validate_string($ldap_group_uuid)
  validate_string($ldap_group_objectsid)
  validate_string($ldap_group_modify_timestamp)
  unless empty($ldap_group_type) { validate_integer($ldap_group_type) }
  unless empty($ldap_group_nesting_level) { validate_integer($ldap_group_nesting_level) }
  unless empty($ldap_groups_use_matching_rule_in_chain) { validate_bool($ldap_groups_use_matching_rule_in_chain) }
  unless empty($ldap_initgroups_use_matching_rule_in_chain) { validate_bool($ldap_initgroups_use_matching_rule_in_chain) }
  unless empty($ldap_use_tokengroups) { validate_bool($ldap_use_tokengroups) }
  validate_string($ldap_netgroup_object_class)
  validate_string($ldap_netgroup_name)
  validate_string($ldap_netgroup_member)
  validate_string($ldap_netgroup_triple)
  validate_string($ldap_netgroup_uuid)
  validate_string($ldap_netgroup_modify_timestamp)
  validate_string($ldap_netgroup_object_class)
  validate_string($ldap_service_name)
  validate_string($ldap_service_port)
  validate_string($ldap_service_proto)
  validate_string($ldap_service_search_base)
  unless empty($ldap_search_timeout) { validate_integer($ldap_search_timeout) }
  unless empty($ldap_enumeration_search_timeout) { validate_integer($ldap_enumeration_search_timeout) }
  unless empty($ldap_network_timeout) { validate_integer($ldap_network_timeout) }
  unless empty($ldap_opt_timeout) { validate_integer($ldap_opt_timeout) }
  unless empty($ldap_page_size) { validate_integer($ldap_page_size) }
  unless empty($ldap_disable_paging) { validate_bool($ldap_disable_paging) }
  unless empty($ldap_disable_range_retrieval) { validate_bool($ldap_disable_range_retrieval) }
  unless empty($ldap_sasl_minssf) { validate_integer($ldap_sasl_minssf) }
  unless empty($ldap_deref_threshold) { validate_integer($ldap_deref_threshold) }
  validate_string($ldap_tls_reqcert)
  validate_array_member($ldap_tls_reqcert,['never','allow','try','demand','hard'])
  unless empty($ldap_tls_cacert) { validate_absolute_path($ldap_tls_cacert) }
  unless empty($ldap_tls_cacertdir) { validate_absolute_path($ldap_tls_cacertdir) }
  unless empty($ldap_tls_cert) { validate_absolute_path($ldap_tls_cert) }
  unless empty($ldap_tls_key) { validate_absolute_path($ldap_tls_key) }
  validate_array($ldap_tls_cipher_suite)
  validate_bool($ldap_id_use_start_tls)
  unless empty($ldap_id_mapping) { validate_bool($ldap_id_mapping) }
  unless empty($ldap_min_id) { validate_integer($ldap_min_id) }
  unless empty($ldap_max_id) { validate_integer($ldap_max_id) }
  validate_string($ldap_sasl_mech)
  validate_string($ldap_sasl_authid)
  validate_string($ldap_sasl_realm)
  unless empty($ldap_sasl_canonicalize) { validate_bool($ldap_sasl_canonicalize) }
  unless empty($ldap_krb5_keytab) { validate_absolute_path($ldap_krb5_keytab) }
  unless empty($ldap_krb5_init_creds) { validate_bool($ldap_krb5_init_creds) }
  unless empty($ldap_krb5_ticket_lifetime) { validate_bool($ldap_krb5_ticket_lifetime) }
  unless empty($krb5_server) { validate_net_list($krb5_server) }
  unless empty($krb5_backup_server) { validate_net_list($krb5_backup_server) }
  validate_string($krb5_realm)
  unless empty($krb5_canonicalize) { validate_bool($krb5_canonicalize) }
  unless empty($krb5_use_kdcinfo) { validate_bool($krb5_use_kdcinfo) }
  validate_string($ldap_pwd_policy)
  validate_array_member($ldap_pwd_policy,['none','shadow','mit_kerberos'])
  unless empty($ldap_referrals) { validate_bool($ldap_referrals) }
  validate_string($ldap_dns_service_name)
  validate_string($ldap_chpass_dns_service_name)
  unless empty($ldap_chpass_update_last_change) { validate_bool($ldap_chpass_update_last_change) }
  validate_string($ldap_access_filter)
  validate_string($ldap_account_expire_policy)
  validate_array_member($ldap_account_expire_policy,['shadow','ad','rhds','ipa','e89ds','nds'])
  validate_array($ldap_access_order)
  validate_array_member($ldap_access_order,['filter','lockout','expire','authorized_service','host'])
  validate_string($ldap_pwdlockout_dn)
  unless empty($ldap_deref) { validate_array_member($ldap_deref,['never','searching','finding','always']) }
  validate_string($ldap_sudorule_object_class)
  validate_string($ldap_sudorule_name)
  validate_string($ldap_sudorule_command)
  validate_string($ldap_sudorule_host)
  validate_string($ldap_sudorule_user)
  validate_string($ldap_sudorule_option)
  validate_string($ldap_sudorule_runasuser)
  validate_string($ldap_sudorule_runasgroup)
  validate_string($ldap_sudorule_notbefore)
  validate_string($ldap_sudorule_notafter)
  validate_string($ldap_sudorule_order)
  unless empty($ldap_sudo_full_refresh_interval){ validate_integer($ldap_sudo_full_refresh_interval) }
  unless empty($ldap_sudo_smart_refresh_interval){ validate_integer($ldap_sudo_smart_refresh_interval) }
  unless empty($ldap_sudo_use_host_filter){ validate_bool($ldap_sudo_use_host_filter) }
  validate_array($ldap_sudo_hostnames)
  validate_net_list($ldap_sudo_hostnames)
  validate_array($ldap_sudo_ip)
  validate_net_list($ldap_sudo_ip)
  unless empty($ldap_sudo_include_netgroups){ validate_bool($ldap_sudo_include_netgroups) }
  unless empty($ldap_sudo_include_regexp){ validate_bool($ldap_sudo_include_regexp) }
  validate_string($ldap_autofs_map_master_name)
  validate_string($ldap_autofs_map_object_class)
  validate_string($ldap_autofs_map_name)
  validate_string($ldap_autofs_entry_object_class)
  validate_string($ldap_autofs_entry_key)
  validate_string($ldap_autofs_entry_value)
  validate_string($ldap_netgroup_search_base)
  validate_string($ldap_user_search_base)
  validate_string($ldap_group_search_base)
  validate_string($ldap_sudo_search_base)
  validate_string($ldap_autofs_search_base)
  unless empty($ldap_idmap_range_min){ validate_integer($ldap_idmap_range_min) }
  unless empty($ldap_idmap_range_max){ validate_integer($ldap_idmap_range_max) }
  unless empty($ldap_idmap_range_size){ validate_integer($ldap_idmap_range_size) }
  validate_string($ldap_idmap_default_domain_sid)
  validate_string($ldap_idmap_default_domain)
  unless empty($ldap_idmap_autorid_compat){ validate_bool($ldap_idmap_autorid_compat) }

  compliance_map()

  include '::sssd'

  $_cert_source = $::sssd::cert_source
  $_use_simp_pki = $::sssd::use_simp_pki

  if empty($ldap_tls_cacertdir) {
    $_ldap_tls_cacertdir = "${_cert_source}/cacerts"
  }
  else {
    $_ldap_tls_cacertdir = $ldap_tls_cacertdir
  }

  if empty($ldap_tls_cert) {
    $_ldap_tls_cert = "${_cert_source}/public/${::fqdn}.pub"
  }
  else {
    $_ldap_tls_cert = $ldap_tls_cert
  }

  if empty($ldap_tls_key) {
    $_ldap_tls_key = "${_cert_source}/private/${::fqdn}.pem"
  }
  else {
    $_ldap_tls_key = $ldap_tls_key
  }

  concat_fragment { "sssd+${name}#ldap_provider.domain":
    content => template('sssd/provider/ldap.erb')
  }
}
