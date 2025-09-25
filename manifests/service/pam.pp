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
    # Build configuration lines in order (matching expected test output)
    # Debug settings
    $description_line = $description ? { undef => [], default => ["description = ${description}"] }
    $debug_level_line = $debug_level ? { undef => [], default => ["debug_level = ${debug_level}"] }
    $debug_timestamps_line = ["debug_timestamps = ${debug_timestamps}"]
    $debug_microseconds_line = ["debug_microseconds = ${debug_microseconds}"]

    # Connection settings
    $reconnection_retries_line = ["reconnection_retries = ${reconnection_retries}"]
    $command_line = $command ? { undef => [], default => ["command = ${command}"] }

    # Offline settings
    $offline_credentials_expiration_line = ["offline_credentials_expiration = ${offline_credentials_expiration}"]
    $offline_failed_login_attempts_line = ["offline_failed_login_attempts = ${offline_failed_login_attempts}"]
    $offline_failed_login_delay_line = ["offline_failed_login_delay = ${offline_failed_login_delay}"]

    # PAM-specific settings
    $pam_verbosity_line = ["pam_verbosity = ${pam_verbosity}"]
    $pam_id_timeout_line = ["pam_id_timeout = ${pam_id_timeout}"]
    $pam_pwd_expiration_warning_line = ["pam_pwd_expiration_warning = ${pam_pwd_expiration_warning}"]
    $pam_cert_auth_line = $pam_cert_auth ? { true => ['pam_cert_auth = True'], false => [] }

    # Optional settings
    $get_domains_timeout_line = $get_domains_timeout ? { undef => [], default => ["get_domains_timeout = ${get_domains_timeout}"] }
    $pam_trusted_users_line = $pam_trusted_users ? { undef => [], default => ["pam_trusted_users = ${pam_trusted_users}"] }
    $pam_public_domains_line = $pam_public_domains ? { undef => [], default => ["pam_public_domains = ${pam_public_domains}"] }

    # Combine all lines in order
    $config_lines = (
      $description_line +
      $debug_level_line +
      $debug_timestamps_line +
      $debug_microseconds_line +
      $reconnection_retries_line +
      $command_line +
      $offline_credentials_expiration_line +
      $offline_failed_login_attempts_line +
      $offline_failed_login_delay_line +
      $pam_verbosity_line +
      $pam_id_timeout_line +
      $pam_pwd_expiration_warning_line +
      $get_domains_timeout_line +
      $pam_trusted_users_line +
      $pam_public_domains_line +
      $pam_cert_auth_line
    )

    # Join all configuration lines
    $content = (['# sssd::service::pam'] + $config_lines).join("\n")

    $_content = epp(
      "${module_name}/generic.epp",
      {
        'title'   => 'pam',
        'content' => $content,
      },
    )
  }

  sssd::config::entry { 'puppet_service_pam':
    content => $_content,
  }
}
