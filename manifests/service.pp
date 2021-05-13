# Control the `sssd` service
#
# @param ensure
#   The `ensure` parameter of the service resource
#
# @param enable
#   The `enable` parameter of the service resource
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service (
  Variant[String[1],Boolean] $ensure = sssd::supported_version(),
  Boolean                    $enable = sssd::supported_version()
){
  assert_private()

  service { 'sssd':
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true
  }
}
