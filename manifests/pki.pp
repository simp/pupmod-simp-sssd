# Class: sssd::pki
#
# Uses the following sssd class parameters to copy certs into
# a directory for the sssd application
#
# $sssd::pki
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
# $ssd::app_pki_cert_source
#   * If $sssd::pki = 'simp' or true, this is the directory from which certs will be
#     copied, via pki::copy.  Defaults to /etc/pki/simp/x509.
#
#   * If $sssd::pki = false, this variable has no effect.
#
class sssd::pki
{
  assert_private()

  include "${module_name}::service"

  if $sssd::pki {
    pki::copy { 'sssd' :
      source => $sssd::app_pki_cert_source,
      pki    => $sssd::pki,
      notify => Class["${module_name}::service"]
    }
  }
}
