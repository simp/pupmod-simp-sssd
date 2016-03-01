# == Class: sssd::service::pam
#
# This class sets up the [pam] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::pam (
  $description                    = '',
  $debug_level                    = '',
  $debug_timestamps               = '',
  $debug_microseconds             = '',
  $reconnection_retries           = '3',
  $command                        = '',
  $offline_credentials_expiration = '0',
  $offline_failed_login_attempts  = '3',
  $offline_failed_login_delay     = '5',
  $pam_verbosity                  = '1',
  $pam_id_timeout                 = '5',
  $pam_pwd_expiration_warning     = '7',
  $get_domains_timeout            = '',
  $pam_trusted_users              = '',
  $pam_public_domains             = ''
) {

  validate_string($description)
  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
  validate_integer($offline_credentials_expiration)
  validate_integer($offline_failed_login_attempts)
  validate_integer($offline_failed_login_delay)
  validate_integer($pam_verbosity)
  validate_integer($pam_id_timeout)
  validate_integer($pam_pwd_expiration_warning)
  unless empty($get_domains_timeout) { validate_integer($get_domains_timeout) }
  validate_string($pam_trusted_users)
  validate_string($pam_public_domains)

  compliance_map()

  concat_fragment { 'sssd+pam.service':
    content => template('sssd/service/pam.erb')
  }
}
