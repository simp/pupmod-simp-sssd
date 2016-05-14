# == Class: sssd::service
#
# Control the SSSD services
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service {

  file { '/etc/init.d/sssd':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => 'puppet:///modules/sssd/sssd.sysinit',
    notify => Service['sssd']
  }

  service { 'nscd':
    ensure => 'stopped',
    enable => false,
    notify => Service['sssd']
  }

  if hiera_array('classes','ipa_server',false) {
    $required_deps = [File['/etc/init.d/sssd'],Service['ipa']]
  }
  else
  {
    $required_deps = File['/etc/init.d/sssd']
  }

  service { 'sssd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [$required_deps],
  }
}
