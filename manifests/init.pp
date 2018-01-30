# This class allows you to install and configure SSSD.
#
# It will forcefully disable nscd which consequently prevents you from
# using an nscd module at the same time, which is the correct behavior.
#
# Full documentation of the parameters that map directly to SSSD
# configuration options can be found in the sssd.conf(5) man page.
#
# @param domains
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param description
# @param config_file_version
# @param services
# @param reconnection_retries
# @param re_expression
# @param full_name_format
# @param try_inotify
# @param krb5_rcache_dir
# @param user
# @param default_domain_suffix
# @param override_space
# @param enumerate_users
#   Have SSSD list and cache all the users that it can find on the remote system
#
#   * Take care that you don't overwhelm your server if you enable this
#
# @param cache_credentials
#   Have SSSD cache the credentials of users that login to the system
#
# @param min_id
#   The lowest user ID that SSSD should recognize from the server.
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
# @param auto_add_ipa_domain
#   Whether to configure sssd for an IPA domain, when the host is joined
#   to an IPA domain. When enabled, this feature helps to prevent user
#   lockout for IPA-managed user accounts.  Otherwise, you must
#   configure the IPA domain yourself.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd (
  Array[String[1, 255], 1]       $domains,
  Optional[Sssd::DebugLevel]     $debug_level           = undef,
  Boolean                        $debug_timestamps      = true,
  Boolean                        $debug_microseconds    = false,
  Optional[String[1]]            $description           = undef,
  Integer                        $config_file_version   = 2,
  Sssd::Services                 $services              = ['nss','pam','ssh','sudo'],
  Integer                        $reconnection_retries  = 3,
  Optional[String[1]]            $re_expression         = undef,
  Optional[String[1]]            $full_name_format      = undef,
  Optional[Boolean]              $try_inotify           = undef,
  Optional[String[1]]            $krb5_rcache_dir       = undef,
  Optional[String[1]]            $user                  = undef,
  Optional[String[1]]            $default_domain_suffix = undef,
  Optional[String[1]]            $override_space        = undef,
  Boolean                        $enumerate_users       = false,
  Boolean                        $cache_credentials     = true,
  Integer                        $min_id                = 500,
  Boolean                        $auditd                = simplib::lookup('simp_options::auditd', { 'default_value' => false}),
  Variant[Boolean,Enum['simp']]  $pki                   = simplib::lookup('simp_options::pki', { 'default_value' => false}),
  Stdlib::Absolutepath           $app_pki_cert_source   = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509'}),
  Stdlib::Absolutepath           $app_pki_dir           = '/etc/pki/simp_apps/sssd/x509',
  Boolean                        $auto_add_ipa_domain   = true
) {

  include 'sssd::install'
  include 'sssd::config'
  include 'sssd::service'

  Class['sssd::install']
  -> Class['sssd::config']
  ~> Class['sssd::service']

  if $auditd {
    include '::auditd'

    auditd::rule { 'sssd':
      content => '-w /etc/sssd/ -p wa -k CFG_sssd'
    }
  }

  if $pki {
    include '::sssd::pki'

    Class['sssd::install'] -> Class['sssd::pki']
    Class['sssd::pki'] ~> Class['sssd::service']
  }
}
