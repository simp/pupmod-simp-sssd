# List of valid values for ldap provider ldap_account_expire_policy
# '' corresponds to the default value (empty) per sssd-ldap(5) man page
type Sssd::LdapAccountExpirePol = Enum['', 'shadow','ad','rhds','ipa','389ds','nds']
