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
# [*$ldap_uri*]
# [*ldap_chpass_uri*]
# [*ldap_search_base*]
# [*ldap_schema*]
# [*ldap_default_bind_dn*]
# [*ldap_default_authtok_type*]
# [*ldap_default_authtok*]
# [*ldap_user_object_class*]
# [*ldap_user_name*]
# [*ldap_user_uid_number*]
# [*ldap_user_gid_number*]
# [*ldap_user_gecos*]
# [*ldap_user_home_directory*]
# [*ldap_user_shell*]
# [*ldap_user_uuid*]
# [*ldap_user_modify_timestamp*]
# [*ldap_user_shadow_last_change*]
# [*ldap_user_shadow_min*]
# [*ldap_user_shadow_max*]
# [*ldap_user_shadow_warning*]
# [*ldap_user_shadow_inactive*]
# [*ldap_user_shadow_expire*]
# [*ldap_user_krb_last_pwd_change*]
# [*ldap_user_krb_password_expiration*]
# [*ldap_user_ad_account_expires*]
# [*ldap_user_ad_user_account_control*]
# [*ldap_ns_account_lock*]
# [*ldap_user_principal*]
# [*ldap_force_upper_case_realm*]
# [*ldap_enumeration_refresh_timeout*]
# [*ldap_purge_cache_timeout*]
# [*ldap_user_fullname*]
# [*ldap_user_member_of*]
# [*ldap_user_authorized_service*]
# [*ldap_group_object_class*]
# [*ldap_group_name*]
# [*ldap_group_gid_number*]
# [*ldap_group_member*]
# [*ldap_group_uuid*]
# [*ldap_group_modify_timestamp*]
# [*ldap_group_nesting_level*]
# [*ldap_netgroup_object_class*]
# [*ldap_netgroup_name*]
# [*ldap_netgroup_member*]
# [*ldap_netgroup_triple*]
# [*ldap_netgroup_uuid*]
# [*ldap_netgroup_modify_timestamp*]
# [*ldap_search_timeout*]
# [*ldap_enumeration_search_timeout*]
# [*ldap_network_timeout*]
# [*ldap_opt_timeout*]
# [*ldap_page_size*]
# [*ldap_tls_reqcert*]
# [*ldap_tls_cacert*]
# [*ldap_tls_cacertdir*]
# [*ldap_tls_cert*]
# [*ldap_tls_key*]
# [*ldap_tls_cipher_suite*]
# Regarding: POODLE - CVE-2014-3566
#
# The tls_cipher_suite variable is set to HIGH:-SSLv2 because OpenLDAP
# cannot set the SSL provider natively. By default, it will run TLSv1
# but cannot handle TLSv1.2 therefore the SSLv3 ciphers cannot be
# eliminated. Take care to ensure that your clients only connect with
# TLSv1 if possible.
#
# [*ldap_id_use_start_tls*]
# [*ldap_sasl_mech*]
# [*ldap_sasl_authid*]
# [*ldap_krb5_keytab*]
# [*ldap_krb5_init_creds*]
# [*ldap_krb5_ticket_lifetime*]
# [*krb5_server*]
# [*krb5_realm*]
# [*ldap_pwd_policy*]
# [*ldap_referrals*]
# [*ldap_dns_service_name*]
# [*ldap_chpass_dns_service_name*]
# [*ldap_access_filter*]
# [*ldap_account_expire_policy*]
# [*ldap_access_order*]
# [*ldap_deref*]
# [*ldap_netgroup_search_base*]
# [*ldap_user_search_base*]
# [*ldap_group_search_base*]
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define sssd::provider::ldap (
# $name
#     The name of the associated domain.
#     section in the configuration file.
  $ldap_uri = hiera('ldap::uri'),
  $ldap_chpass_uri = hiera('ldap::master'),
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
  $ldap_user_principal = '',
  $ldap_force_upper_case_realm = '',
  $ldap_enumeration_refresh_timeout = '',
  $ldap_purge_cache_timeout = '',
  $ldap_user_fullname = '',
  $ldap_user_member_of = '',
  $ldap_user_authorized_service = '',
  $ldap_group_object_class = '',
  $ldap_group_name = '',
  $ldap_group_gid_number = '',
  $ldap_group_member = '',
  $ldap_group_uuid = '',
  $ldap_group_modify_timestamp = '',
  $ldap_group_nesting_level = '',
  $ldap_netgroup_object_class = '',
  $ldap_netgroup_name = '',
  $ldap_netgroup_member = '',
  $ldap_netgroup_triple = '',
  $ldap_netgroup_uuid = '',
  $ldap_netgroup_modify_timestamp = '',
  $ldap_search_timeout = '6',
  $ldap_enumeration_search_timeout = '60',
  $ldap_network_timeout = '6',
  $ldap_opt_timeout = '6',
  $ldap_page_size = '1000',
  $ldap_tls_reqcert = 'demand',
  $ldap_tls_cacert = '',
  $ldap_tls_cacertdir = '/etc/pki/cacerts',
  $ldap_tls_cert = "/etc/pki/public/${::fqdn}.pub",
  $ldap_tls_key = "/etc/pki/private/${::fqdn}.pem",
  $ldap_tls_cipher_suite = hiera('openssl::cipher_suite',[
    'HIGH',
    '-SSLv2'
  ]),
  $ldap_id_use_start_tls = true,
  $ldap_sasl_mech = '',
  $ldap_sasl_authid = '',
  $ldap_krb5_keytab = '',
  $ldap_krb5_init_creds = '',
  $ldap_krb5_ticket_lifetime = '',
  $krb5_server = '',
  $krb5_realm = '',
  $ldap_pwd_policy = 'shadow',
  $ldap_referrals = '',
  $ldap_dns_service_name = '',
  $ldap_chpass_dns_service_name = '',
  $ldap_access_filter = '',
  $ldap_account_expire_policy = 'shadow',
  $ldap_access_order = 'expire,filter',
  $ldap_deref = '',
#Be careful with the following options!
  $ldap_netgroup_search_base = '',
  $ldap_user_search_base = '',
  $ldap_group_search_base = ''
) {
  include 'openldap::pam'

  concat_fragment { "sssd+${name}#ldap_provider.domain":
    content => template('sssd/provider/ldap.erb')
  }

  # The following should be removed when SSSD can handle shadow password
  # changes in LDAP.

  include 'openldap::pam'

  validate_absolute_path($ldap_tls_cert)
  validate_absolute_path($ldap_tls_key)
  validate_array($ldap_tls_cipher_suite)
  validate_bool($ldap_id_use_start_tls)
}
