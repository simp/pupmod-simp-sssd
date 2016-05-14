# == Define: sssd::provider::ipa
#
# This define sets up the 'ipa' provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# == Parameters
# See sssd-ipa.conf(5) for additional information.
#
# [*name*]
#   The name of the associated domain section in the configuration file.
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define sssd::provider::ipa (
  $debug_level = '',
  $debug_timestamps = '',
  $debug_microseconds = '',
  $ipa_hostname,
  $ipa_domain,
  $ipa_server,
  $ipa_ldap_tls_cacert = '/etc/ipa/ca.crt',
  $ipa_krb5_store_password_if_offline = 'True',
) {

  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }

  include '::sssd'

  concat_fragment { "sssd+${name}#ipa_provider.domain":
    content => template('sssd/provider/ipa.erb')
  }
}
