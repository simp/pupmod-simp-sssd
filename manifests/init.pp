# == Class: sssd
#
# This class allows you to install and configure SSSD.
#
# It will forcefully disable nscd which consequently prevents you from using an
# nscd module at the same time, which is the correct behavior.  ---
#
# == Parameters:
#
# [*pki*]
# Type: Variant[Boolean,Enum['simp']]
# Default: false
#   A flag, which if enabled, allows SIMP to distribute PKI certs/keys from
#   app_pki_cert_source.
#   If set to 'simp' then copy the keys, plus install pki module so simp will
#   copy certs from puppet server.
#
# [*use_tls*]
# Type: Boolean
# Default: true
#   If enabled, use encryption on connections .
#
# [*app_pki_cert_source*]
# Type: Stdlib::Absolutepath
# Default: '/etc/pki/simp'
#   The path from where certificates are copied if pki = true or simp. Put your certs here
#   using pki directory format if pki = true.
#
# [*app_pki_dir*]
# Type: Stdlib::Absolutepath
# Default: '/etc/pki/sssd'
# This is the directory where the active certs are.  If pki = true or simp, pki::copy
# will copy the certs into this directory.  if pki is false, put the certs under
# here.  Make sure you use the directory structure used by pki or set the app_pki*
# variables used by the ldap provider.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd (
  Array                          $domains,
  String                         $debug_level           = '',
  Variant[Boolean,String]        $debug_timestamps      = '',
  Variant[Boolean,String]        $debug_microseconds    = '',
  String                         $description           = '',
  Stdlib::Compat::Integer        $config_file_version   = '2',
  Array[String]                  $services              = ['nss','pam','ssh','sudo'],
  Stdlib::Compat::Integer        $reconnection_retries  = '3',
  String                         $re_expression         = '',
  String                         $full_name_format      = '',
  Variant[Boolean,String]        $try_inotify           = '',
  String                         $krb5_rcache_dir       = '',
  String                         $user                  = '',
  String                         $default_domain_suffix = '',
  String                         $override_space        = '',
  Boolean                        $use_tls               = true,
  Boolean                        $auditd                = simplib::lookup('simp_options::auditd', { 'default_value' => false}),
  Variant[Boolean,Enum['simp']]  $pki                   = simplib::lookup('simp_options::pki', { 'default_value' => false}),
  Stdlib::Absolutepath           $app_pki_cert_source   = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp'}),
  Stdlib::Absolutepath           $app_pki_dir           = '/etc/pki/sssd'
) {

#  validate_array_member($services,['nss','pam','sudo','autofs','ssh','pac'])
#  unless empty($krb5_rcache_dir) {
#    unless $krb5_rcache_dir == '__LIBKRB5_DEFAULTS__' {
#      validate_absolute_path($krb5_rcache_dir)
#    }
#  }

  include '::sssd::install'
  include '::sssd::service'

  if $auditd {
    include '::auditd'

    auditd::add_rules { 'sssd':
      content => '-w /etc/sssd/ -p wa -k CFG_sssd'
    }
  }

  simpcat_build { 'sssd':
    order  => ['*.conf', '*.service', '*.domain'],
    target => '/etc/sssd/sssd.conf',
    notify => [
      File['/etc/sssd/sssd.conf'],
      Class['sssd::service']
    ]
  }

  simpcat_fragment { 'sssd+sssd.conf':
    content => template('sssd/sssd.conf.erb')
  }

  if $use_tls {
      include '::sssd::config::pki'

      Class['sssd::install'] -> Class['sssd::config::pki']
      Class['sssd::config::pki'] ~> Class['sssd::service']
    }

  Class['sssd::install'] ~> Class['sssd::service']
}
