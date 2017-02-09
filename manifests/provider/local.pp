# == Define: sssd::provider::local
#
# This define sets up the 'local' id_provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# == Parameters
# See 'The local domain section' in sssd.conf(5) for additional information.
#
# [*name*]
#   The name of the associated domain section in the configuration file.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define sssd::provider::local (
  Optional[Sssd::DebugLevel]      $debug_level        = undef,
  Boolean                         $debug_timestamps   = true,
  Boolean                         $debug_microseconds = false,
  Optional[String]                $default_shell      = undef,
  Optional[Stdlib::Absolutepath]  $base_directory     = undef,
  Boolean                         $create_homedir     = true,
  Boolean                         $remove_homedir     = true,
  Optional[Simplib::Umask]        $homedir_umask      = undef,
  Optional[Stdlib::Absolutepath]  $skel_dir           = undef,
  Optional[Stdlib::Absolutepath]  $mail_dir           = undef,
  Optional[String]                $userdel_cmd        = undef
) {
  include '::sssd'

  concat::fragment { "sssd_${name}_local_provider.domain":
    target  => '/etc/sssd/sssd.conf',
    content => template('sssd/provider/local.erb')
  }
}
