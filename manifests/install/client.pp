# Install the sssd-client package
#
# @param ensure
#   Ensure setting for 'sssd-client' package
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::install::client (
  $ensure = $::sssd::install::ensure
){
  package { 'sssd-client': ensure => $ensure }
}
