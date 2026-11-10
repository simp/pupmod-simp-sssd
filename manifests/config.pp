#
# Configuration class called from sssd.
#
# Manages the ``[sssd]`` section of '/etc/sssd/sssd.conf' and, optionally, a
# domain section for the IPA domain to which the host is joined.  When the IPA
# domain is configured, it is automatically added to the ``domains`` setting.
#
# Each setting is edited in place and only when its parameter is set, so a
# bare ``include sssd`` declares nothing here.
#
# @param authoritative
#   Set to `true` to purge unmanaged configuration files
#
# @param manage_base_domain
#   Declare a ``LOCAL`` proxy domain for the local ``files``
#
#   * Like any other domain, it is only used once it is listed, e.g. with
#     ``sssd::domains_entries: { LOCAL: {} }``.
#   * EL10+ requires a domain to be configured in order for SSSD to start, and
#     SSSD 2.10 no longer provides the implicit files domain that EL8/9 have.
#   * Off by default; the `simp:defaults` profile turns it on for EL10.
#
# @param sssd_config_dir_mode
#   The mode to set on the /etc/sssd and /etc/sssd/conf.d directories and,
#   recursively, on the files within /etc/sssd/conf.d
#
#   * Unset, the directories are not managed.
#
# @param sssd_config_file_params
#   A hash of parameters to apply to every file this module edits in /etc/sssd
#   and /etc/sssd/conf.d.  This should include at least the owner, group, and
#   mode parameters.
#
#   * SSSD refuses to start with an `sssd.conf`, and ignores a `conf.d`
#     snippet, whose ownership and permissions it doesn't accept, so a file is
#     only edited with these applied.  The module data holds what each
#     release's SSSD expects.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::config (
  Boolean             $authoritative           = pick(getvar("${module_name}::authoritative"), false),
  Boolean             $manage_base_domain      = false,
  Optional[String[1]] $sssd_config_dir_mode    = undef,
  Hash                $sssd_config_file_params = {},
) {
  assert_private()

  include $module_name

  $_sssd_conf = '/etc/sssd/sssd.conf'

  if $sssd::auto_add_ipa_domain and ($facts.dig('ipa', 'connected') or $sssd::force_ipa_domain) {
    # this host has joined an IPA domain, or the operator is forcing the
    # IPA domain to be configured ahead of the join
    $_ipa_domain_name = pick_default($facts.dig('ipa', 'domain'), $sssd::ipa_domain_name)
    if empty($_ipa_domain_name) {
      fail('The IPA domain must be provided by the ipa fact or set via sssd::ipa_domain_name')
    }
    $_ipa_domain = { $_ipa_domain_name => 'present' }
    include 'sssd::config::ipa_domain'
  }
  else {
    $_ipa_domain = {}
  }

  $_domains = sssd::entries($sssd::domains_entries, $sssd::domains) + $_ipa_domain
  $_services = sssd::entries($sssd::services_entries, $sssd::services)

  # Every responder class is included, listed or not, so a responder setting
  # enforced on its own takes effect.  A class with no parameters set manages
  # nothing.
  if $sssd::include_svc_config {
    ['nss', 'pam', 'ssh', 'sudo', 'autofs', 'ifp', 'pac'].each |$_service| {
      include "sssd::service::${_service}"
    }
  }

  if $sssd_config_dir_mode {
    file { '/etc/sssd':
      ensure  => 'directory',
      mode    => $sssd_config_dir_mode,
      require => Package['sssd'],
    }
  }

  if $sssd_config_dir_mode or $authoritative {
    file { '/etc/sssd/conf.d':
      ensure  => 'directory',
      mode    => $sssd_config_dir_mode,
      purge   => $authoritative,
      recurse => true,
      require => Package['sssd'],
    }
  }

  if $sssd::tidy_puppet_snippets and !$authoritative {
    tidy { '/etc/sssd/conf.d':
      matches => '*_puppet_*.conf',
      recurse => true,
    }
  }

  # Options SSSD 2.10 removed from its schema (config_file_version,
  # reconnection_retries, enable_files_domain) are still accepted here for the
  # releases that read them; the simp:defaults profile sets them on EL8/9 only.
  sssd::config::entry { 'sssd':
    section  => 'sssd',
    path     => $_sssd_conf,
    settings => {
      'description'              => $sssd::description,
      'config_file_version'      => $sssd::config_file_version,
      'reconnection_retries'     => $sssd::reconnection_retries,
      're_expression'            => $sssd::re_expression,
      'full_name_format'         => $sssd::full_name_format,
      'try_inotify'              => $sssd::try_inotify,
      'krb5_rcache_dir'          => $sssd::krb5_rcache_dir,
      'user'                     => $sssd::user,
      'default_domain_suffix'    => $sssd::default_domain_suffix,
      'override_space'           => $sssd::override_space,
      'certificate_verification' => $sssd::certificate_verification,
      'enable_files_domain'      => $sssd::enable_files_domain,
      'debug_level'              => $sssd::debug_level,
      'debug_timestamps'         => $sssd::debug_timestamps,
      'debug_microseconds'       => $sssd::debug_microseconds,
    },
  }

  # The services and domains lists are edited one entry at a time, so a list
  # entry added by anything else stays in place.  sudo is never listed: its
  # responder has to be started by its socket, which refuses to start while
  # sudo is in the list, so a sudo entry removes it.
  $_lists = {
    'services' => $_services.map |$_service, $_ensure| {
      [$_service, $_service ? { 'sudo' => 'absent', default => $_ensure }]
    }.convert_to(Hash),
    'domains'  => $_domains,
  }

  $_lists.each |$_setting, $_entries| {
    unless empty($_entries) {
      ensure_resource('file', $_sssd_conf, $sssd_config_file_params + {
          'ensure'  => 'file',
          'require' => Package['sssd'],
      })
    }

    $_entries.each |$_entry, $_ensure| {
      ini_subsetting { "sssd ${_sssd_conf} [sssd] ${_setting} ${_entry}":
        ensure               => $_ensure,
        path                 => $_sssd_conf,
        section              => 'sssd',
        setting              => $_setting,
        subsetting           => $_entry,
        subsetting_separator => ',',
        key_val_separator    => ' = ',
        use_exact_match      => true,
        delete_if_empty      => true,
        require              => [Package['sssd'], File[$_sssd_conf]],
        notify               => Class["${module_name}::service"],
      }
    }
  }

  if $manage_base_domain {
    sssd::domain { 'LOCAL':
      id_provider       => 'proxy',
      proxy_lib_name    => 'files',
      auth_provider     => 'none',
      access_provider   => 'permit',
      cache_credentials => false,
      enumerate         => false,
    }
  }
}
