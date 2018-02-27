# Define: sssd::provider::krb5
#
# This define sets up the 'krb5' provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# See sssd-krb5.conf(5) for additional information.
#
# @param name
#   The name of the associated domain section in the configuration file.
#
# @param krb5_server
# @param krb5_realm
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param krb5_kpasswd
# @param krb5_ccachedir
# @param krb5_ccname_template
# @param krb5_auth_timeout
# @param krb5_validate
# @param krb5_keytab
# @param krb5_store_password_if_offline
# @param krb5_renewable_lifetime
# @param krb5_lifetime
# @param krb5_renew_interval
# @param krb5_use_fast
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::provider::krb5 (
  Simplib::Host                          $krb5_server,
  String                                 $krb5_realm,
  Optional[Sssd::DebugLevel]             $debug_level                    = undef,
  Boolean                                $debug_timestamps               = true,
  Boolean                                $debug_microseconds             = false,
  Optional[String]                       $krb5_kpasswd                   = undef,
  Optional[Stdlib::Absolutepath]         $krb5_ccachedir                 = undef,
  Optional[Stdlib::Absolutepath]         $krb5_ccname_template           = undef,
  Integer                                $krb5_auth_timeout              = 15,
  Boolean                                $krb5_validate                  = false,
  Optional[Stdlib::Absolutepath]         $krb5_keytab                    = undef,
  Boolean                                $krb5_store_password_if_offline = false,
  Optional[String]                       $krb5_renewable_lifetime        = undef,
  Optional[String]                       $krb5_lifetime                  = undef,
  Integer                                $krb5_renew_interval            = 0,
  Optional[Enum['never','try','demand']] $krb5_use_fast                  = undef
) {
  include '::sssd'

  concat::fragment { "sssd_${name}_krb5_provider.domain":
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/provider/krb5.erb"),
    order   => $name
  }
}
