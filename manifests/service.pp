# Control the `sssd` service
#
# The service is only declared when `ensure` or `enable` is set.  Either may
# be left `undef`, which leaves that half of the service unmanaged.
#
# With the service unmanaged, configuration changes are written to disk but
# are not loaded into a running `sssd` until it is restarted, e.g. with
# `systemctl restart sssd`.
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
  Optional[Variant[String[1],Boolean]] $ensure = undef,
  Optional[Boolean]                    $enable = undef,
) {
  assert_private()

  if $ensure =~ NotUndef or $enable =~ NotUndef {
    service { 'sssd':
      ensure     => $ensure,
      enable     => $enable,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
