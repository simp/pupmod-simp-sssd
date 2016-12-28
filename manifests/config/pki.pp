# == Class: sssd::pki
#
#  
#
class sssd::config::pki
{
  assert_private()


  $pki = $::sssd::pki
  $source = $::sssd::app_pki_cert_source
  $app_pki_dir = $::sssd::app_pki_dir

  file { "${app_pki_dir}" :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }

  if $pki {
    ::pki::copy { "${app_pki_dir}" :
      source => $source,
      pki    => $pki
    }
  }
    
}
