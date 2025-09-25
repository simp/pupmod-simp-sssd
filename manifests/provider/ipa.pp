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
  Simplib::Hostname              $ipa_hostname                   = $facts['networking']['fqdn'],
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
  Boolean                        $use_service_discovery          = true,
) {
  # Build configuration lines in order (matching expected test output)
  # IPA domain configuration (required)
  $ipa_domain_line = ["ipa_domain = ${ipa_domain}"]

  # IPA server configuration with service discovery logic
  $ipa_server_line = $use_service_discovery ? {
    true => ["ipa_server = _srv_,${ipa_server.join(',')}"],
    false => ["ipa_server = ${ipa_server.join(',')}"]
  }

  # IPA backup server configuration (optional)
  $ipa_backup_server_line = $ipa_backup_server ? { undef => [], default => ["ipa_backup_server = ${ipa_backup_server.join(',')}"] }

  # IPA boolean settings (required)
  $ipa_enable_dns_sites_line = ["ipa_enable_dns_sites = ${ipa_enable_dns_sites}"]
  $ipa_hostname_line = ["ipa_hostname = ${ipa_hostname}"]
  $ipa_server_mode_line = ["ipa_server_mode = ${ipa_server_mode}"]

  # Dynamic DNS settings
  $dyndns_auth_line = ["dyndns_auth = ${dyndns_auth}"]
  $dyndns_force_tcp_line = $dyndns_force_tcp ? { undef => [], default => ["dyndns_force_tcp = ${dyndns_force_tcp}"] }
  $dyndns_iface_line = $dyndns_iface ? { undef => [], default => ["dyndns_iface = ${dyndns_iface.join(',')}"] }
  $dyndns_refresh_interval_line = $dyndns_refresh_interval ? { undef => [], default => ["dyndns_refresh_interval = ${dyndns_refresh_interval}"] }
  $dyndns_server_line = $dyndns_server ? { undef => [], default => ["dyndns_server = ${dyndns_server}"] }
  $dyndns_ttl_line = $dyndns_ttl ? { undef => [], default => ["dyndns_ttl = ${dyndns_ttl}"] }
  $dyndns_update_line = ["dyndns_update = ${dyndns_update}"]
  $dyndns_update_ptr_line = $dyndns_update_ptr ? { undef => [], default => ["dyndns_update_ptr = ${dyndns_update_ptr}"] }

  # IPA-specific optional settings
  $ipa_automount_location_line = $ipa_automount_location ? { undef => [], default => ["ipa_automount_location = ${ipa_automount_location}"] }
  $ipa_hbac_refresh_line = $ipa_hbac_refresh ? { undef => [], default => ["ipa_hbac_refresh = ${ipa_hbac_refresh}"] }
  $ipa_hbac_search_base_line = $ipa_hbac_search_base ? { undef => [], default => ["ipa_hbac_search_base = ${ipa_hbac_search_base}"] }
  $ipa_hbac_selinux_line = $ipa_hbac_selinux ? { undef => [], default => ["ipa_hbac_selinux = ${ipa_hbac_selinux}"] }
  $ipa_host_search_base_line = $ipa_host_search_base ? { undef => [], default => ["ipa_host_search_base = ${ipa_host_search_base}"] }
  $ipa_master_domains_search_base_line = $ipa_master_domains_search_base ? { undef => [], default => ["ipa_master_domains_search_base = ${ipa_master_domains_search_base}"] }
  $ipa_selinux_search_base_line = $ipa_selinux_search_base ? { undef => [], default => ["ipa_selinux_search_base = ${ipa_selinux_search_base}"] }
  $ipa_subdomains_search_base_line = $ipa_subdomains_search_base ? { undef => [], default => ["ipa_subdomains_search_base = ${ipa_subdomains_search_base}"] }
  $ipa_views_search_base_line = $ipa_views_search_base ? { undef => [], default => ["ipa_views_search_base = ${ipa_views_search_base}"] }

  # Kerberos settings
  $krb5_confd_path_line = $krb5_confd_path ? { undef => [], default => ["krb5_confd_path = ${krb5_confd_path}"] }
  $krb5_realm_line = $krb5_realm ? { undef => [], default => ["krb5_realm = ${krb5_realm}"] }
  $krb5_store_password_if_offline_line = ["krb5_store_password_if_offline = ${krb5_store_password_if_offline}"]

  # LDAP TLS settings (required)
  $ldap_tls_cacert_line = ["ldap_tls_cacert = ${ldap_tls_cacert}"]
  $ldap_tls_cipher_suite_line = ["ldap_tls_cipher_suite = ${ldap_tls_cipher_suite.join(':')}"]

  # Combine all lines in order
  $config_lines = (
    $ipa_domain_line +
    $ipa_server_line +
    $ipa_backup_server_line +
    $ipa_enable_dns_sites_line +
    $ipa_hostname_line +
    $ipa_server_mode_line +
    $dyndns_auth_line +
    $dyndns_force_tcp_line +
    $dyndns_iface_line +
    $dyndns_refresh_interval_line +
    $dyndns_server_line +
    $dyndns_ttl_line +
    $dyndns_update_line +
    $dyndns_update_ptr_line +
    $ipa_automount_location_line +
    $ipa_hbac_refresh_line +
    $ipa_hbac_search_base_line +
    $ipa_hbac_selinux_line +
    $ipa_host_search_base_line +
    $ipa_master_domains_search_base_line +
    $ipa_selinux_search_base_line +
    $ipa_subdomains_search_base_line +
    $ipa_views_search_base_line +
    $krb5_confd_path_line +
    $krb5_realm_line +
    $krb5_store_password_if_offline_line +
    $ldap_tls_cacert_line +
    $ldap_tls_cipher_suite_line
  )

  # Join all configuration lines
  $content = (['# sssd::provider::ipa'] + $config_lines).join("\n")

  sssd::config::entry { "puppet_provider_${name}_ipa":
    content => epp(
      "${module_name}/generic.epp",
      {
        'title'   => "domain/${title}",
        'content' => $content,
      },
    ),
  }
}
