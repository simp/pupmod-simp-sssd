# == Class: sssd::pki
#
# Ensures that there are PKI certificates readable by the rsyslog user in
# /etc/sssd/pki
#
class sssd::config::pki {
  assert_private()

  unless empty($::sssd::cert_source) { validate_absolute_path($::sssd::cert_source) }

  if $::sssd::use_simp_pki {
    include '::pki'
    ::pki::copy { '/etc/sssd': }
  }
  else {
    file { '/etc/sssd/pki':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0640'
    }
  }
}
