# Generate the proper ldap_access_order defaults based on the version of SSSD
# in place
#
# @return [Array[String]]
#
function sssd::ldap_access_order_defaults {
  $_defaults = [
    'expire',
    'lockout'
  ]

  if $facts['sssd_version'] {
    if versioncmp($facts['sssd_version'], '1.14.0') >= 0 {
      $_result = [
        'ppolicy',
        'pwd_expire_policy_reject'
      ]
    }
  }

  if defined('$_result') {
    $_defaults + $_result
  }
  else {
    $_defaults
  }
}
