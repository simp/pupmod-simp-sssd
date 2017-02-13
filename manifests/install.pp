# == Class: sssd::install
#
# Install the required packages for SSSD
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::install {
  contain '::sssd::install::client'

  file { $sssd::conf_dir_path:
    ensure  => 'directory',
    owner   => $sssd::conf_dir_owner,
    group   => 'root',
    mode    => '0640',
    require => Package[$sssd::package_name]
  }

  file { $sssd::conf_file_path:
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0600'
  }

  package { $sssd::package_name:
    ensure => $sssd::package_version
  }

  if $sssd::install_user_tools {
    package { $sssd::tools_package_name:
      ensure => $sssd::tools_package_version
    }
  }
}
