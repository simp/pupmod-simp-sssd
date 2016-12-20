# == Class: sssd::pki
#
# Ensures that there are PKI certificates readable by the rsyslog user in
# /etc/sssd/pki
#
class sssd::config::pki
{
  assert_private()


  $pki = $::sssd::pki
  $source = $::sssd::app_pki_cert_source
  $app_pki_dir = $::sssd::app_pki_dir

  if $pki {

    if $pki == 'simp' { include '::pki' }
    ::pki::copy { "${app_pki_dir}" :
      source => $source,
      pki    => $pki
    }
  }
  else {
    file { "${app_pki_dir}/pki" :
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0640'
    }
  }
}
