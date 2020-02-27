# List of valid values for ldap provider ldap_access_order setting
type Sssd::LdapAccessOrder = Array[Enum[
  'filter',
  'lockout',
  'ppolicy', # Only available in sssd >= 1.14.0
  'expire',
  'pwd_expire_policy_reject', # Only available in sssd >= 1.14.0
  'pwd_expire_policy_warn', # Only available in sssd >= 1.14.0
  'pwd_expire_policy_renew', # Only available in sssd >= 1.14.0
  'authorized_service',
  'host'
]]
