# == Class: sssd
#
# This class allows you to install and configure SSSD.
#
# It will forcefully disable nscd which consequently prevents you from using an
# nscd module at the same time, which is the correct behavior.  ---
#
# == Parameters:
#
# [*enable_pki*]
# Type: Boolean
# Default: true
#   A flag, which if enabled, allows SIMP to distribute PKI certs/keys for Rsyslog.
#
# [*use_simp_pki*]
# Type: String
# Default: true
#   If enabled, use the SIMP PKI module for supplying the PKI credentials to the system.
#
# [*cert_source*]
# Type: String
# Default: ''
#   The path to client certificates dir, if using local (SIMP-independent) PKI
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd (
  $domains,
  $debug_level = '',
  $debug_timestamps = '',
  $debug_microseconds = '',
  $description           = '',
  $config_file_version   = '2',
  $services              = ['nss','pam','ssh','sudo'],
  $reconnection_retries  = '3',
  $re_expression         = '',
  $full_name_format      = '',
  $try_inotify           = '',
  $krb5_rcache_dir       = '',
  $user                  = '',
  $default_domain_suffix = '',
  $override_space        = '',
  $enable_auditd         = true,
  $enable_pki            = defined('$::enable_pki') ? { true => $::enable_pki, default => hiera('enable_pki',true) },
  $use_simp_pki = defined('$::use_simp_pki') ? { true => $::use_simp_pki, default => hiera('use_simp_pki', true) },
  $cert_source           = '/etc/sssd/pki'
) {

  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
  validate_integer($config_file_version)
  validate_array_member($services,['nss','pam','sudo','autofs','ssh','pac'])
  validate_integer($reconnection_retries)
  unless empty($re_expression) { validate_string($re_expression) }
  unless empty($full_name_format) { validate_string($full_name_format) }
  unless empty($try_inotify) { validate_bool($try_inotify) }
  unless empty($krb5_rcache_dir) {
    unless $krb5_rcache_dir == '__LIBKRB5_DEFAULTS__' {
      validate_absolute_path($krb5_rcache_dir)
    }
  }
  validate_string($user)
  validate_string($default_domain_suffix)
  validate_string($override_space)
  validate_bool($enable_auditd)
  validate_bool($enable_pki)
  validate_bool($use_simp_pki)
  validate_absolute_path($cert_source)

  compliance_map()

  include '::sssd::install'
  include '::sssd::service'

  if $enable_auditd {
    include '::auditd'

    auditd::add_rules { 'sssd':
      content => '-w /etc/sssd/ -p wa -k CFG_sssd'
    }
  }

  concat_build { 'sssd':
    order  => ['*.conf', '*.service', '*.domain'],
    target => '/etc/sssd/sssd.conf',
    notify => [
      File['/etc/sssd/sssd.conf'],
      Class['sssd::service']
    ]
  }

  concat_fragment { 'sssd+sssd.conf':
    tag     => 'sssd_simp_fragment',
    target  => '/etc/sssd/sssd.conf',
    content => template('sssd/sssd.conf.erb')
  }

  if $enable_pki {
    if $use_simp_pki {
      include '::sssd::config::pki'

      Class['sssd::install'] -> Class['sssd::config::pki']
      Class['sssd::config::pki'] ~> Class['sssd::service']
    }
  }

  Class['sssd::install'] ~> Class['sssd::service']
}
