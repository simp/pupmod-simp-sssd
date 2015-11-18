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
  $install_user_tools = true
) {

  validate_bool($install_user_tools)

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
    mode    => '0600'
  }

  package { 'sssd': ensure => 'latest' }

  if $install_user_tools {
    package { 'sssd-tools': ensure => 'latest' }
  }
}
