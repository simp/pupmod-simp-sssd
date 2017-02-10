# == Class: sssd::install::client
#
# Install the sssd-client package
#
class sssd::install::client {
  package { $sssd::client_package_name: ensure => $sssd::client_package_version }
}
