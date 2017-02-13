# == Class: sssd::service
#
# Control the SSSD services
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>

class sssd::service {

  file { $sssd::sssd_service_path:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0754',
    seltype => 'sssd_initrc_exec_t',
    source  => 'puppet:///modules/sssd/sssd.sysinit',
    notify  => Service[$sssd::sssd_service_name]
  }

  service { $sssd::nscd_service_name:
    ensure => 'stopped',
    enable => false,
    notify => Service[$sssd::sssd_service_name]
  }

  service { $sssd::sssd_service_name:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File[$sssd::sssd_service_path]
  }
}
