# This class sets up the [pam] section of /etc/sssd.conf.
# You may only have one of these per system.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param pam_cert_auth
# @param reconnection_retries
# @param command
# @param offline_credentials_expiration
# @param offline_failed_login_attempts
# @param offline_failed_login_delay
# @param pam_verbosity
# @param pam_id_timeout
# @param pam_pwd_expiration_warning
# @param get_domains_timeout
# @param pam_trusted_users
# @param pam_public_domains
#
# @param custom_options
#   If defined, this hash will be used to create the service
#   section instead of the parameters.  You must provide all options
#   in the section you want to add.  Each entry in the hash will be
#   added as a simple init pair key = value under the section in
#   the sssd.conf file.
#   No error checking will be performed.
#

# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::pam (
  Optional[String]             $description                    = undef,
  Optional[Sssd::DebugLevel]   $debug_level                    = undef,
  Boolean                      $debug_timestamps               = true,
  Boolean                      $debug_microseconds             = false,
  Boolean                      $pam_cert_auth                  = false,
  Integer                      $reconnection_retries           = 3,
  Optional[String]             $command                        = undef,
  Integer                      $offline_credentials_expiration = 0,
  Integer                      $offline_failed_login_attempts  = 3,
  Integer                      $offline_failed_login_delay     = 5,
  Integer                      $pam_verbosity                  = 1,
  Integer                      $pam_id_timeout                 = 5,
  Integer                      $pam_pwd_expiration_warning     = 7,
  Optional[Integer]            $get_domains_timeout            = undef,
  Optional[String]             $pam_trusted_users              = undef,
  Optional[String]             $pam_public_domains             = undef,
  Optional[Hash]               $custom_options                 = undef,
) {
  if $custom_options {
    $_content = epp(
      "${module_name}/service/custom_options.epp",
      {
        'service_name' => 'pam',
        'options'      => $custom_options,
      },
    )
  } else {
    $_content = epp(
      "${module_name}/service/pam.epp",
      {
        'description'                    => $description,
        'debug_level'                    => $debug_level,
        'debug_timestamps'               => $debug_timestamps,
        'debug_microseconds'             => $debug_microseconds,
        'pam_cert_auth'                  => $pam_cert_auth,
        'reconnection_retries'           => $reconnection_retries,
        'command'                        => $command,
        'offline_credentials_expiration' => $offline_credentials_expiration,
        'offline_failed_login_attempts'  => $offline_failed_login_attempts,
        'offline_failed_login_delay'     => $offline_failed_login_delay,
        'pam_verbosity'                  => $pam_verbosity,
        'pam_id_timeout'                 => $pam_id_timeout,
        'pam_pwd_expiration_warning'     => $pam_pwd_expiration_warning,
        'get_domains_timeout'            => $get_domains_timeout,
        'pam_trusted_users'              => $pam_trusted_users,
        'pam_public_domains'             => $pam_public_domains,
      },
    )
  }

  sssd::config::entry { 'puppet_service_pam':
    content => $_content,
  }
}
