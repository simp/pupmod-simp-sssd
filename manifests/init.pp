# This class allows you to install and configure SSSD.
#
# It will forcefully disable nscd which consequently prevents you from using an
# nscd module at the same time, which is the correct behavior
#
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
# @param app_pki_external_source
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
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd (
  Array[String]                  $domains,
  Optional[Sssd::DebugLevel]     $debug_level           = undef,
  Boolean                        $debug_timestamps      = true,
  Boolean                        $debug_microseconds    = false,
  Optional[String]               $description           = undef,
  Integer                        $config_file_version   = 2,
  Sssd::Services                 $services              = ['nss','pam','ssh','sudo'],
  Integer                        $reconnection_retries  = 3,
  Optional[String]               $re_expression         = undef,
  Optional[String]               $full_name_format      = undef,
  Optional[Boolean]              $try_inotify           = undef,
  Optional[String]               $krb5_rcache_dir       = undef,
  Optional[String]               $user                  = undef,
  Optional[String]               $default_domain_suffix = undef,
  Optional[String]               $override_space        = undef,
  Boolean                        $auditd                = simplib::lookup('simp_options::auditd', { 'default_value' => false}),
  Variant[Boolean,Enum['simp']]  $pki                   = simplib::lookup('simp_options::pki', { 'default_value' => false}),
  Stdlib::Absolutepath           $app_pki_cert_source   = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509'}),
  Stdlib::Absolutepath           $app_pki_dir           = '/etc/pki/simp_apps/sssd/x509'
) {

  include '::sssd::install'
  include '::sssd::service'

  if $auditd {
    include '::auditd'

    auditd::rule { 'sssd':
      content => '-w /etc/sssd/ -p wa -k CFG_sssd'
    }
  }

  concat { '/etc/sssd/sssd.conf':
    owner          => 'root',
    group          => 'root',
    mode           => '0640',
    ensure_newline => true,
    warn           => true,
    notify         => Class['sssd::service']
  }

  concat::fragment { 'sssd_main_config':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/sssd.conf.erb")
  }

  if $pki {
    include '::sssd::pki'

    Class['sssd::install'] -> Class['sssd::pki']
    Class['sssd::pki'] ~> Class['sssd::service']
  }

  Class['sssd::install'] ~> Class['sssd::service']
}
