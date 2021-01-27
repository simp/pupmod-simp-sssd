# == Class: sssd::service
# Control the SSSD services
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service {
  service { 'nscd':
    ensure => 'stopped',
    enable => false,
    notify => Service['sssd']
  }

  service { 'sssd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}
