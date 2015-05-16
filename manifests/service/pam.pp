# == Class: sssd::service::pam
#
# This class sets up the [pam] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# == Parameters
# See sssd.conf(5) for descriptions of most variables.
#
# [*description*]
# [*debug_level*]
# [*debug_timestamps*]
# [*reconnection_retries*]
# [*command*]
# [*offline_credentials_expiration*]
# [*offline_failed_login_attempts*]
# [*offline_failed_login_delay*]
# [*pam_verbosity*]
# [*pam_id_timeout*]
# [*pam_pwd_expiration_warning*]
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::pam (
  $description = '',
  $debug_level = '',
  $debug_timestamps = '',
  $reconnection_retries = '3',
  $command = '',
  $offline_credentials_expiration = '0',
  $offline_failed_login_attempts = '3',
  $offline_failed_login_delay = '5',
  $pam_verbosity = '1',
  $pam_id_timeout = '5',
  $pam_pwd_expiration_warning = '7'
) {

  concat_fragment { 'sssd+pam.service':
    content => template('sssd/service/pam.erb')
  }
}
