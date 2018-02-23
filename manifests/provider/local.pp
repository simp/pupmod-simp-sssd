# Define: sssd::provider::local
#
# This define sets up the 'local' id_provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# See 'The local domain section' in sssd.conf(5) for additional information.
#
# @param name
#   The name of the associated domain section in the configuration file.
#
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param default_shell
# @param base_directory
# @param create_homedir
# @param remove_homedir
# @param homedir_umask
# @param skel_dir
# @param mail_dir
# @param userdel_cmd
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
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
    content => template('sssd/provider/local.erb'),
    order   => $name
  }
}
