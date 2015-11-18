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
  $debug_level = '',
  $debug_timestamps = '',
  $debug_microseconds = '',
  $default_shell = '',
  $base_directory = '',
  $create_homedir = '',
  $remove_homedir = '',
  $homedir_umask = '',
  $skel_dir = '',
  $mail_dir = '',
  $userdel_cmd = ''
) {

  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }

  concat_fragment { "sssd+${name}#local_provider.domain":
    content => template('sssd/provider/local.erb')
  }
}
