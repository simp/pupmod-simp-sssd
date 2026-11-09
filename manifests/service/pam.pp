# This class sets up the [pam] section of /etc/sssd/sssd.conf.
# You may only have one of these per system.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# Each parameter that maps to a setting follows three states: `undef` (the
# default) leaves the setting alone, a value sets it, and `'absent'` removes
# it.  The class manages nothing until one of them is set.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param pam_cert_auth
#   `true` writes `pam_cert_auth = True` and `false` writes `pam_cert_auth = False`.
# @param reconnection_retries
#   Removed from SSSD's schema in 2.10, with no successor.  The
#   `simp:defaults` profile sets it on the releases that still accept it.
#
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
#   If defined, these settings are managed in the section *instead of* the
#   ones from the other parameters, which are then ignored.  Each entry is
#   edited in place as `key = value` in the generated `/etc/sssd/conf.d/`
#   drop-in file; a value of `'absent'` removes that setting.
#   No error checking will be performed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::pam (
  Optional[String]                                    $description                    = undef,
  Optional[Variant[Sssd::DebugLevel, Enum['absent']]] $debug_level                    = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_timestamps               = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_microseconds             = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $pam_cert_auth                  = undef,
  Optional[Variant[Integer, Enum['absent']]]          $reconnection_retries           = undef,
  Optional[String]                                    $command                        = undef,
  Optional[Variant[Integer, Enum['absent']]]          $offline_credentials_expiration = undef,
  Optional[Variant[Integer, Enum['absent']]]          $offline_failed_login_attempts  = undef,
  Optional[Variant[Integer, Enum['absent']]]          $offline_failed_login_delay     = undef,
  Optional[Variant[Integer, Enum['absent']]]          $pam_verbosity                  = undef,
  Optional[Variant[Integer, Enum['absent']]]          $pam_id_timeout                 = undef,
  Optional[Variant[Integer, Enum['absent']]]          $pam_pwd_expiration_warning     = undef,
  Optional[Variant[Integer, Enum['absent']]]          $get_domains_timeout            = undef,
  Optional[String]                                    $pam_trusted_users              = undef,
  Optional[String]                                    $pam_public_domains             = undef,
  Optional[Hash]                                      $custom_options                 = undef,
) {
  $_settings = $custom_options ? {
    undef   => {
      'description'                    => $description,
      'debug_level'                    => $debug_level,
      'debug_timestamps'               => $debug_timestamps,
      'debug_microseconds'             => $debug_microseconds,
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
      'pam_cert_auth'                  => $pam_cert_auth ? { true => 'True', false => 'False', default => $pam_cert_auth },
    },
    default => $custom_options,
  }

  sssd::config::entry { 'puppet_service_pam':
    section  => 'pam',
    settings => $_settings,
  }
}
