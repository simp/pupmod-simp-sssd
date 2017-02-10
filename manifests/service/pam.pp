# == Class: sssd::service::pam
#
# This class sets up the [pam] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
# == Parameters available to this template
# command
# debug_level
# debug_timestamps
# debug_microseconds
# description
# get_domains_timeout
# offline_credentials_expiration
# offline_failed_login_attempts
# offline_failed_login_delay
# pam_id_timeout
# pam_pwd_expiration_warning
# pam_public_domains
# pam_trusted_users
# pam_verbosity
# reconnection_retries

class sssd::service::pam {

  include '::sssd'

  # These varaibles are referenced inside the autofs template, and
  # because we don't want to worry about scope inside of the template
  # we handle it here.

  $description                    = $sssd::description
  $debug_level                    = $sssd::debug_level
  $debug_timestamps               = $sssd::debug_timestamps
  $debug_microseconds             = $sssd::debug_microseconds
  $reconnection_retries           = $sssd::reconnection_retries
  $command                        = $sssd::command
  $offline_credentials_expiration = $sssd::offline_credentials_expiration
  $offline_failed_login_attempts  = $sssd::offline_failed_login_attempts
  $offline_failed_login_delay     = $sssd::offline_failed_login_delay
  $pam_verbosity                  = $sssd::pam_verbosity
  $pam_id_timeout                 = $sssd::pam_id_timeout
  $pam_pwd_expiration_warning     = $sssd::pam_pwd_expiration_warning
  $get_domains_timeout            = $sssd::get_domains_timeout
  $pam_trusted_users              = $sssd::pam_trusted_users
  $pam_public_domains             = $sssd::pam_public_domains

  concat::fragment { 'sssd_pam.service':
    target  => $sssd::conf_file_path,
    content => template("${module_name}/service/pam.erb")
  }
}
