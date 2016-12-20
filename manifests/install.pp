# == Class: sssd::install
#
# Install the required packages for SSSD
#
# == Parameters:
#
# [*install_user_tools*]
# Type: Boolean
# Default: true
#   If true, install the 'sssd-tools' for administrative changes to the SSSD
#   databases.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::install (
  Boolean  $install_user_tools = true
) {
  contain '::sssd::install::client'


  if ( $::operatingsystem in ['RedHat','CentOS'] ) and ( $::operatingsystemmajrelease > '6' ) { 
    $_sssd_user = 'sssd'
  } else {
    $_sssd_user = 'root'
  }

  file { '/etc/sssd':
    ensure  => 'directory',
    owner   => $_sssd_user,
    group   => 'root',
    mode    => '0640',
    require => Package['sssd']
  }

  file { '/etc/sssd/sssd.conf':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0600'
  }

  package { 'sssd': ensure => 'latest' }

  if $install_user_tools {
    package { 'sssd-tools': ensure => 'latest' }
  }
}
