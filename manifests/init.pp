# This class allows you to install and configure SSSD.
#
# A bare `include sssd` installs the SSSD packages and does nothing else.
# Everything else is opt-in: each setting is written only when its parameter
# is set, and each is edited in place, so settings this module does not
# manage are left alone. Enforce the `simp:defaults` compliance_engine profile
# to restore the behavior of earlier releases (see the README).
#
# The parameters that map to `[sssd]` settings in `/etc/sssd/sssd.conf`
# follow the same three states:
#
# * `undef` (the default) leaves the setting alone
# * a value sets it
# * `'absent'` removes it
#
# Full documentation of the parameters that map directly to SSSD
# configuration options can be found in the sssd.conf(5) man page.
#
# @param authoritative
#   Purge every file in /etc/sssd/conf.d that this catalog does not manage
#
#   * **Destructive:** this deletes snippets written by the OS, other tools,
#     an administrator, or an earlier Puppet run with different settings.
#
# @param tidy_puppet_snippets
#   Delete the `*_puppet_*.conf` files in /etc/sssd/conf.d that this catalog
#   does not manage
#
#   * **Destructive:** a snippet written by an earlier run, for settings this
#     run no longer manages, is deleted along with those settings.
#   * Has no effect when `authoritative` is `true`, which purges them anyway.
#
# @param domains_entries
#   The domains to list in the `domains` setting, each mapped to its options
#
#   * Listing a domain does **not** create it; declare `sssd::domain` and an
#     `sssd::provider::*` with the same name as well.
#   * Each entry is added to or, with `ensure => absent`, removed from the
#     list on its own; domains listed by anything else are left alone.
#   * The IPA domain (`auto_add_ipa_domain`) is added automatically. The
#     `LOCAL` domain (`sssd::config::manage_base_domain`) is not; list it
#     here, as the `simp:defaults` profile does on EL10.
#
# @option domains_entries [Enum['present', 'absent']] :ensure
#   `absent` removes the domain from the list. Defaults to `present`.
#
# @param domains
#   Deprecated: use `domains_entries`
#
#   Domains to add to the `domains` setting. An entry prefixed with `--` is
#   removed from it instead.
#
#   * While this is set, even to `[]`, `domains_entries` is ignored, because
#     this list replaced the module's default before 11.0.0.
#   * An entry dropped from this list is no longer managed and stays listed;
#     remove it with a `--<name>` entry, or with `ensure => absent` in
#     `domains_entries` once this is unset.
#
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param description
#
# @param enable_files_domain
#   Whether to write the ``enable_files_domain`` option into the ``[sssd]``
#   section.
#
#   * SSSD 2.10 dismantled the implicit files domain and removed this option
#     from its schema, so the module supplies it from ``data/os/`` only on the
#     releases that still accept it and leaves it ``undef`` elsewhere.  On
#     EL10+ the equivalent is a proxy domain with ``proxy_lib_name => 'files'``,
#     which ``sssd::config::manage_base_domain`` creates as the ``LOCAL``
#     domain.
#   * An explicitly set value is always written, on every release.
#
# @param config_file_version
#   Whether to write the ``config_file_version`` option into the ``[sssd]``
#   section, and what value to use.
#
#   * SSSD 2.10 removed this option as obsolete, with no successor.  Supplied
#     from ``data/os/`` on the releases that still accept it; ``undef``
#     elsewhere.
#
# @param services_entries
#   The responder services to list in the `services` setting, each mapped to
#   its options
#
#   * `sudo` is never listed, and is removed from the list wherever it has an
#     entry, because the sudo responder is socket-activated (see
#     `sssd::service::sudo::socket_enable`).
#   * Each entry is added to or, with `ensure => absent`, removed from the
#     list on its own; services listed by anything else are left alone.
#
# @option services_entries [Enum['present', 'absent']] :ensure
#   `absent` removes the service from the list. Defaults to `present`.
#
# @param services
#   Deprecated: use `services_entries`
#
#   Services to add to the `services` setting.
#
#   * While this is set, even to `[]`, `services_entries` is ignored, because
#     this list replaced the module's default before 11.0.0.
#   * An entry dropped from this list is no longer managed and stays listed;
#     to remove it, unset this and set `ensure => absent` for it in
#     `services_entries`.
#
# @param reconnection_retries
#   Whether to write the ``reconnection_retries`` option into the ``[sssd]``
#   section, and what value to use.
#
#   * SSSD 2.10 removed this option -- it had already stopped being read --
#     with no successor.  Supplied from ``data/os/`` on the releases that
#     still accept it; ``undef`` elsewhere.
#
# @param re_expression
# @param full_name_format
# @param try_inotify
# @param krb5_rcache_dir
# @param user
# @param default_domain_suffix
# @param override_space
# @param certificate_verification
#   Value of the ``certificate_verification`` option written to the ``[sssd]``
#   section.  Used to tune OCSP/CRL behavior for smartcard authentication.
#   Accepts a comma-separated list of tokens (e.g., ``ocsp_dgst=sha1, no_ocsp``)
#   per ``sssd.conf(5)``.
# @param ldap_providers
#   This allows users to set up ldap sssd::provider::ldap resources via hieradata
# @example sssd::provider::ldap in hieradata:
#   sssd::ldap_providers:
#     ldap_users:
#       ldap_access_filter: 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com'
#       ldap_chpass_uri: empty
#       ldap_access_order: 'expire'
#       etc...
#
# @param enumerate_users
#   Have SSSD list and cache all the users that it can find on the remote
#   system, in the domain created by `auto_add_ipa_domain`
#
#   * Take care that you don't overwhelm your server if you enable this
#
# @param include_svc_config
#   Include every `sssd::service::<name>` class, so that each responder's
#   section is managed from that class's parameters, whether or not the
#   responder is listed in `services_entries`. Each of those classes manages
#   only the settings whose parameters are set, so with none set they manage
#   nothing. Turn this off to manage the responder sections yourself.
#
# @param cache_credentials
#   Have SSSD cache the credentials of users that login to the system, in the
#   domain created by `auto_add_ipa_domain`
#
# @param min_id
#   The lowest user ID that SSSD should recognize from the server, in the
#   domain created by `auto_add_ipa_domain`
#
# @param auditd
# @param pki
#   * If 'simp', include SIMP's pki module and use pki::copy to manage
#     application certs in /etc/pki/simp_apps/sssd/x509
#   * If true, do *not* include SIMP's pki module, but still use pki::copy
#     to manage certs in /etc/pki/simp_apps/sssd/x509
#   * If false, do not include SIMP's pki module and do not use pki::copy
#     to manage certs.  You will need to appropriately assign a subset of:
#     * app_pki_dir
#     * app_pki_key
#     * app_pki_cert
#     * app_pki_ca
#     * app_pki_ca_dir
#
# @param app_pki_cert_source
#   * If pki = 'simp' or true, this is the directory from which certs will be
#     copied, via pki::copy.  Defaults to /etc/pki/simp/x509.
#
#   * If pki = false, this variable has no effect.
#
# @param app_pki_dir
#   This variable controls the basepath of $app_pki_key, $app_pki_cert,
#   $app_pki_ca, $app_pki_ca_dir, and $app_pki_crl.
#   It defaults to /etc/pki/simp_apps/sssd/x509.
#
# @param app_pki_group
#   Group ownership applied to the certificates copied by ``pki::copy``
#   when ``$pki`` is ``'simp'`` or ``true``.
#
#   * The sssd processes must be able to read the copied TLS private key,
#     so this must be a group the runtime sssd user belongs to.  On EL10+,
#     where sssd runs as the unprivileged ``sssd`` user, this defaults to
#     ``'sssd'``; on releases where sssd runs as root it remains ``'root'``.
#
#   * If ``$pki`` = ``false``, this variable has no effect.
#
# @param auto_add_ipa_domain
#   Whether to configure sssd for an IPA domain, when the host is joined
#   to an IPA domain. When enabled, this feature helps to prevent user
#   lockout for IPA-managed user accounts.  Otherwise, you must
#   configure the IPA domain yourself.
#
#   * Off by default; the `simp:defaults` profile turns it on.
#
# @param force_ipa_domain
#   Configure sssd for the IPA domain even when the ``ipa`` fact reports
#   ``connected => false`` (or is absent).  Useful when pre-staging
#   configuration before the host has actually joined the realm.
#
#   * When the ``ipa`` fact is missing or incomplete, ``ipa_domain_name``
#     and ``ipa_servers`` must be supplied.
#
# @param ipa_domain_name
#   The IPA domain name to use when ``force_ipa_domain`` is enabled and
#   ``$facts['ipa']['domain']`` is not available.
#
# @param ipa_servers
#   The IPA servers to use when ``force_ipa_domain`` is enabled and
#   ``$facts['ipa']['server']`` is not available.
#
# @param custom_config
#   Raw configuration that will be written to
#   /etc/sssd/conf.d/99999_puppet_custom_raw.conf *without validation*
#
#   * The file holds exactly this content, and nothing else
#   * It sorts after the file `custom_settings` edits, so a setting in both
#     takes this file's value
#
#   * `'absent'` removes the file
#   * Prefer `custom_settings` unless you need something the structured form
#     cannot express
#
# @param custom_settings
#   Settings to manage in /etc/sssd/conf.d/99999_puppet_custom.conf,
#   expressed as a Hash of section name to setting name to value
#
#   * Unlike `custom_config`, the section names, setting names, and values are
#     type-validated at compile time, and each setting is edited in place
#   * Unlike the per-section `custom_options` parameters, this *adds* sections
#     rather than replacing a section the module already manages
#   * Settings with an `undef` value are left alone, settings with the value
#     `'absent'` are removed, and Array values are written as comma-separated
#     lists
#
# @example Adding a section via `custom_settings`
#   sssd::custom_settings:
#     'certmap/EXAMPLE.COM/rule1':
#       matchrule: '<ISSUER>CN=Example CA'
#       maprule: '(userCertificate;binary={cert!bin})'
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd (
  Boolean                                             $authoritative            = false,
  Boolean                                             $tidy_puppet_snippets     = false,
  Hash[String[1, 255], Sssd::EntryOptions]            $domains_entries          = {},
  Optional[Array[String[1, 255]]]                     $domains                  = undef,
  Optional[Variant[Sssd::DebugLevel, Enum['absent']]] $debug_level              = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_timestamps         = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_microseconds       = undef,
  Optional[String[1]]                                 $description              = undef,
  Optional[Variant[Integer[1], Enum['absent']]]       $config_file_version      = undef,
  Hash[Sssd::Service, Sssd::EntryOptions]             $services_entries         = {},
  Optional[Sssd::Services]                            $services                 = undef,
  Optional[Variant[Integer[0], Enum['absent']]]       $reconnection_retries     = undef,
  Optional[String[1]]                                 $re_expression            = undef,
  Optional[String[1]]                                 $full_name_format         = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $try_inotify              = undef,
  Optional[String[1]]                                 $krb5_rcache_dir          = undef,
  Optional[String[1]]                                 $user                     = undef,
  Optional[String[1]]                                 $default_domain_suffix    = undef,
  Optional[String[1]]                                 $override_space           = undef,
  Optional[String[1]]                                 $certificate_verification = undef,
  Hash                                                $ldap_providers           = {},
  Optional[Variant[Boolean, Enum['absent']]]          $enable_files_domain      = undef,
  Boolean                                             $enumerate_users          = false,
  Boolean                                             $cache_credentials        = true,
  Boolean                                             $include_svc_config       = true,
  Integer[0]                                          $min_id                   = 1,
  Boolean                                             $auditd                   = simplib::lookup('simp_options::auditd', { 'default_value' => false }),
  Variant[Boolean,Enum['simp']]                       $pki                      = simplib::lookup('simp_options::pki', { 'default_value' => false }),
  Stdlib::Absolutepath                                $app_pki_cert_source      = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509' }),
  Stdlib::Absolutepath                                $app_pki_dir              = '/etc/pki/simp_apps/sssd/x509',
  String[1]                                           $app_pki_group            = 'root',
  Boolean                                             $auto_add_ipa_domain      = false,
  Boolean                                             $force_ipa_domain         = false,
  Optional[String[1]]                                 $ipa_domain_name          = undef,
  Optional[Array[Simplib::Host,1]]                    $ipa_servers              = undef,
  Optional[Variant[String[1], Enum['absent']]]        $custom_config            = undef,
  Optional[Sssd::IniSettings]                         $custom_settings          = undef,
) {
  include 'sssd::install'
  include 'sssd::config'
  include 'sssd::service'

  unless sssd::supported_version() {
    fail "The ${module_name} module does not support SSSD < ${facts['sssd_version']}. Please update your system to continue."
  }

  Class['sssd::install'] -> Class['sssd::config']

  if $domains =~ NotUndef {
    deprecation('sssd::domains', 'sssd::domains is deprecated and will be removed in a future major release; use sssd::domains_entries instead. While sssd::domains is set, sssd::domains_entries is ignored.', false)
  }

  if $services =~ NotUndef {
    deprecation('sssd::services', 'sssd::services is deprecated and will be removed in a future major release; use sssd::services_entries instead. While sssd::services is set, sssd::services_entries is ignored.', false)
  }

  # One entry per section, all edited in place in the same file.
  pick_default($custom_settings, {}).each |$_section, $_settings| {
    sssd::config::entry { "puppet_custom ${_section}":
      section  => $_section,
      settings => $_settings,
      path     => '/etc/sssd/conf.d/99999_puppet_custom.conf',
    }
  }

  # Raw configuration can't be edited in place, so it gets a file of its own
  # that holds only this parameter's content. It sorts after the
  # custom_settings file, so it wins where both set the same setting.
  if $custom_config == 'absent' {
    file { '/etc/sssd/conf.d/99999_puppet_custom_raw.conf':
      ensure => 'absent',
      notify => Class['sssd::service'],
    }
  }
  elsif $custom_config {
    file { '/etc/sssd/conf.d/99999_puppet_custom_raw.conf':
      *       => $sssd::config::sssd_config_file_params,
      ensure  => 'file',
      content => "${custom_config}\n",
      require => Package['sssd'],
      notify  => Class['sssd::service'],
    }
  }

  if $pki {
    simplib::assert_optional_dependency($module_name, 'simp/pki')

    include 'sssd::pki'

    Class['sssd::config'] -> Class['sssd::pki']
  }

  if $auditd {
    simplib::assert_optional_dependency($module_name, 'simp/auditd')

    include 'auditd'

    auditd::rule { 'sssd':
      content => '-w /etc/sssd/ -p wa -k CFG_sssd',
    }
  }

  $ldap_providers.each |$key, $value| {
    sssd::provider::ldap { $key:
      * => $value,
    }
  }
}
