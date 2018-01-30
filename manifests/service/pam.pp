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
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::pam (
  Optional[String]             $description                    = undef,
  Optional[Sssd::DebugLevel]   $debug_level                    = undef,
  Boolean                      $debug_timestamps               = true,
  Boolean                      $debug_microseconds             = false,
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
  Optional[String]             $pam_public_domains             = undef
) {
  include '::sssd'

  concat::fragment { 'sssd_pam.service':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/service/pam.erb")
  }
}
