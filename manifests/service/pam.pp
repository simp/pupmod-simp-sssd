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
    # Build configuration content for the PAM service
    $_base_content = [
      '# sssd::service::pam',
    ]

    # Add conditional parameters if defined
    if $description {
      $_description_entries = ["description = ${description}"]
    } else {
      $_description_entries = []
    }

    if $debug_level {
      $_debug_level_entries = ["debug_level = ${debug_level}"]
    } else {
      $_debug_level_entries = []
    }

    $_debug_timestamps_entries = $debug_timestamps ? {
      true  => ['debug_timestamps = true'],
      false => ['debug_timestamps = false'],
    }

    $_debug_microseconds_entries = $debug_microseconds ? {
      true  => ['debug_microseconds = true'],
      false => ['debug_microseconds = false'],
    }

    $_reconnection_retries_entries = ["reconnection_retries = ${reconnection_retries}"]

    if $command {
      $_command_entries = ["command = ${command}"]
    } else {
      $_command_entries = []
    }

    $_offline_credentials_expiration_entries = ["offline_credentials_expiration = ${offline_credentials_expiration}"]
    $_offline_failed_login_attempts_entries = ["offline_failed_login_attempts = ${offline_failed_login_attempts}"]
    $_offline_failed_login_delay_entries = ["offline_failed_login_delay = ${offline_failed_login_delay}"]
    $_pam_verbosity_entries = ["pam_verbosity = ${pam_verbosity}"]
    $_pam_id_timeout_entries = ["pam_id_timeout = ${pam_id_timeout}"]
    $_pam_pwd_expiration_warning_entries = ["pam_pwd_expiration_warning = ${pam_pwd_expiration_warning}"]

    if $get_domains_timeout {
      $_get_domains_timeout_entries = ["get_domains_timeout = ${get_domains_timeout}"]
    } else {
      $_get_domains_timeout_entries = []
    }

    if $pam_trusted_users {
      $_pam_trusted_users_entries = ["pam_trusted_users = ${pam_trusted_users}"]
    } else {
      $_pam_trusted_users_entries = []
    }

    if $pam_public_domains {
      $_pam_public_domains_entries = ["pam_public_domains = ${pam_public_domains}"]
    } else {
      $_pam_public_domains_entries = []
    }

    $_pam_cert_auth_entries = $pam_cert_auth ? {
      true  => ['pam_cert_auth = True'],
      false => [],
    }

    # Combine all configuration entries in the expected order
    $_all_entries = $_base_content + $_description_entries + $_debug_level_entries + $_debug_timestamps_entries + $_debug_microseconds_entries + $_reconnection_retries_entries + $_command_entries + $_offline_credentials_expiration_entries + $_offline_failed_login_attempts_entries + $_offline_failed_login_delay_entries + $_pam_verbosity_entries + $_pam_id_timeout_entries + $_pam_pwd_expiration_warning_entries + $_get_domains_timeout_entries + $_pam_trusted_users_entries + $_pam_public_domains_entries + $_pam_cert_auth_entries

    $_final_content = $_all_entries.join("\n")

    $_content = epp(
      "${module_name}/service/pam.epp",
      {
        'content' => $_final_content,
      },
    )
  }

  sssd::config::entry { 'puppet_service_pam':
    content => $_content,
  }
}
