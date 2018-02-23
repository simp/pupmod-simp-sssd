# This define sets up the 'ipa' provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# See sssd-ipa.conf(5) for additional information.
#
# Regarding: POODLE - CVE-2014-3566
#
# The tls_cipher_suite variable is set to HIGH:-SSLv2 by default because
# OpenLDAP cannot set the SSL provider natively. By default, it will run TLSv1
# but cannot handle TLSv1.2 therefore the SSLv3 ciphers cannot be eliminated.
# Take care to ensure that your clients only connect with TLSv1 if possible.
#
# @param name
# @param ipa_domain
# @param ipa_server
# @param ipa_backup_server
# @param ipa_enable_dns_sites
# @param ipa_hostname
# @param ipa_server_mode
# @param dyndns_auth
# @param dyndns_force_tcp
# @param dyndns_iface
# @param dyndns_refresh_interval
# @param dyndns_server
# @param dyndns_ttl
# @param dyndns_update
# @param dyndns_update_ptr
# @param ipa_automount_location
# @param ipa_hbac_refresh
# @param ipa_hbac_search_base
# @param ipa_hbac_selinux
# @param ipa_host_search_base
# @param ipa_master_domains_search_base
# @param ipa_selinux_search_base
# @param ipa_subdomains_search_base
# @param ipa_views_search_base
# @param krb5_confd_path
# @param krb5_realm
# @param krb5_store_password_if_offline
# @param ldap_tls_cacert
# @param ldap_tls_cipher_suite
# @param use_service_discovery  Whether to add '_srv_' to the list of IPA servers,
#   thereby enabling service discovery of these servers
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::provider::ipa (
  String[1]                      $ipa_domain,
  Array[Simplib::Host]           $ipa_server,
  Optional[Array[Simplib::Host]] $ipa_backup_server              = undef,
  Boolean                        $ipa_enable_dns_sites           = false,
  Simplib::Hostname              $ipa_hostname                   = $facts['fqdn'],
  Boolean                        $ipa_server_mode                = false,
  Enum['none','GSS-TSIG']        $dyndns_auth                    = 'GSS-TSIG',
  Optional[Boolean]              $dyndns_force_tcp               = undef,
  Optional[Array[String[1]]]     $dyndns_iface                   = undef,
  Optional[Integer[0]]           $dyndns_refresh_interval        = undef,
  Optional[Simplib::Host]        $dyndns_server                  = undef,
  Optional[Integer[0]]           $dyndns_ttl                     = undef,
  Boolean                        $dyndns_update                  = true,
  Optional[Boolean]              $dyndns_update_ptr              = undef,
  Optional[String]               $ipa_automount_location         = undef,
  Optional[Integer[0]]           $ipa_hbac_refresh               = undef,
  Optional[String]               $ipa_hbac_search_base           = undef,
  Optional[Integer[0]]           $ipa_hbac_selinux               = undef,
  Optional[String]               $ipa_host_search_base           = undef,
  Optional[String]               $ipa_master_domains_search_base = undef,
  Optional[String]               $ipa_selinux_search_base        = undef,
  Optional[String]               $ipa_subdomains_search_base     = undef,
  Optional[String]               $ipa_views_search_base          = undef,
  Optional[Stdlib::AbsolutePath] $krb5_confd_path                = undef,
  Optional[String]               $krb5_realm                     = undef,
  Boolean                        $krb5_store_password_if_offline = true,
  Stdlib::AbsolutePath           $ldap_tls_cacert                = '/etc/ipa/ca.crt',
  Array[String]                  $ldap_tls_cipher_suite          = ['HIGH','-SSLv2'],
  Boolean                        $use_service_discovery          = true

) {
  include '::sssd'

  if $use_service_discovery {
    $_ipa_server = ['_srv_'] + $ipa_server
  }
  else {
    $_ipa_server = $ipa_server
  }

  concat::fragment { "sssd_${name}_ipa_provider.domain":
    target  => '/etc/sssd/sssd.conf',
    content => template('sssd/provider/ipa.erb'),
    order   => $name
  }
}
