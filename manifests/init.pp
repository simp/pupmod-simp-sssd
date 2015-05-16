# == Class: sssd
#
# This class allows you to install and configure SSSD.
#
# It will forcefully disable nscd which consequently prevents you from using an
# nscd module at the same time, which is the correct behavior.  ---
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd (
  $domains,
  $description = '',
  $config_file_version = '2',
  $services = ['nss','pam'],
  $reconnection_retries = '3',
  $re_expression = '',
  $full_name_format = '',
  $try_inotify = true,
  $use_auditd = true
) {
  include 'pki'

  if $use_auditd {
    include 'auditd'
    auditd::add_rules { 'sssd':
      content => '-w /etc/sssd/ -p wa -k CFG_sssd'
    }
  }

  concat_build { 'sssd':
    order  => ['*.conf', '*.service', '*.domain'],
    target => '/etc/sssd/sssd.conf',
    notify => File['/etc/sssd/sssd.conf']
  }

  concat_fragment { 'sssd+sssd.conf':
    content => template('sssd/sssd.conf.erb')
  }

  file { '/etc/init.d/sssd':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0754',
    source  => 'puppet:///modules/sssd/sssd.sysinit',
    require => Package['sssd'],
    notify  => Service['sssd']
  }

  file { '/etc/sssd':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }

  file { '/etc/sssd/sssd.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    notify  => Service['sssd'],
    require => Package['sssd']
  }

  package { 'sssd':
    ensure => 'latest'
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
    require    => Package['sssd'],
    subscribe  => [
      File['/etc/pki/cacerts'],
      File["/etc/pki/public/${::fqdn}.pub"],
      File["/etc/pki/private/${::fqdn}.pem"]
    ]
  }

  validate_integer($config_file_version)
  validate_array_member($services,['nss','pam','sudo','autofs','ssh','pac'])
  validate_integer($reconnection_retries)
  validate_bool($try_inotify)
  validate_bool($use_auditd)
}
