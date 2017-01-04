# == Define: sssd::provider::krb5
#
# This define sets up the 'krb5' provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# == Parameters
# See sssd-krb5.conf(5) for additional information.
#
# [*name*]
#   The name of the associated domain section in the configuration file.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define sssd::provider::krb5 (
  $krb5_server,
  $krb5_realm,
  $debug_level = '',
  $debug_timestamps = '',
  $debug_microseconds = '',
  $krb5_kpasswd = '',
  $krb5_ccachedir = '',
  $krb5_ccname_template = '',
  $krb5_auth_timeout = '15',
  $krb5_validate = '',
  $krb5_keytab = '',
  $krb5_store_password_if_offline = '',
  $krb5_renewable_lifetime = '',
  $krb5_lifetime = '',
  $krb5_renew_interval = '',
  $krb5_use_fast = ''
) {

#  validate_string($debug_level)
#  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
#  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }

  simpcat_fragment { "sssd+${name}#krb5_provider.domain":
    content => template('sssd/provider/krb5.erb')
  }
}
