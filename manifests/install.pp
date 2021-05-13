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
  String   $package_ensure     = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {
  assert_private()
  include 'sssd::install::client'

  package { ['sssd', 'sssd-dbus']:
    ensure => $package_ensure
  }

  if $install_user_tools {
    package { 'sssd-tools':
      ensure => $package_ensure
    }
  }
}
