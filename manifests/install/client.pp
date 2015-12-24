# == Class: sssd::install::client
#
# Install the sssd-client package
#
class sssd::install::client (
  $ensure = 'latest'
){
  package { 'sssd-client': ensure => $ensure }
}
