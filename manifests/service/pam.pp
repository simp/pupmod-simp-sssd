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
  Optional[String]   $description                    = undef,
  Optional[String]   $debug_level                    = undef,
  Boolean            $debug_timestamps               = true,
  Boolean            $debug_microseconds             = false,
  Integer            $reconnection_retries           = 3,
  Optional[String]   $command                        = undef,
  Integer            $offline_credentials_expiration = 0,
  Integer            $offline_failed_login_attempts  = 3,
  Integer            $offline_failed_login_delay     = 5,
  Integer            $pam_verbosity                  = 1,
  Integer            $pam_id_timeout                 = 5,
  Integer            $pam_pwd_expiration_warning     = 7,
  Optional[Integer]  $get_domains_timeout            = undef,
  Optional[String]   $pam_trusted_users              = undef,
  Optional[String]   $pam_public_domains             = undef
) {
  include '::sssd'

  concat::fragment { 'sssd_pam.service':
    target  => '/etx/sssd/sssd.conf',
    content => template("${module_name}/service/pam.erb")
  }
}
