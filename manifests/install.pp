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

  file { '/etc/sssd':
    ensure  => 'directory',
    group   => 'root',
    mode    => '0711',
    require => Package['sssd']
  }

  package { 'sssd': ensure => $package_ensure }

  if $install_user_tools {
    package { 'sssd-tools': ensure => $package_ensure }
  }
}
