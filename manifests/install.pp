# Install the required packages for SSSD
#
# @param install_user_tools
#   If ``true``, install the 'sssd-tools' package for administrative
#   changes to the SSSD databases
#
# @param package_ensure
#   Ensure setting for all packages installed by this module
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::install (
  Boolean  $install_user_tools = true,
  String   $package_ensure     = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'latest' }),
) {
  contain 'sssd::install::client'

  if ( $facts['operatingsystem'] in ['RedHat','CentOS'] ) and ( $facts['operatingsystemmajrelease'] > '6' ) {
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

  package { 'sssd': ensure => $package_ensure }

  if $install_user_tools {
    package { 'sssd-tools': ensure => $package_ensure }
  }
}
