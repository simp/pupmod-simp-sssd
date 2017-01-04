# == Class: sssd::pki
#
class sssd::config::pki
{
  assert_private()

  file { $::sssd::app_pki_dir :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }

  if $::sssd::pki {
    ::pki::copy { $::sssd::app_pki_dir :
      source => $::sssd::app_pki_cert_source,
      pki    => $::sssd::pki
    }
  }
  else {
    file { "${::sssd::app_pki_dir}/pki" :
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0640'
    }
  }
}
