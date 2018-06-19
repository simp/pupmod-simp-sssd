# == Class: sssd::service
# Control the SSSD services
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service {

  file { '/etc/init.d/sssd':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    seltype => 'sssd_initrc_exec_t',
    source  => 'puppet:///modules/sssd/sssd.sysinit',
    notify  => Service['sssd']
  }

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
    require    => File['/etc/init.d/sssd']
  }
}
