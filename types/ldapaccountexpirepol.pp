# '' corresponds to the default value (empty) per sssd-ldap(5) man page
type Sssd::LdapAccountExpirePol = Enum['', 'shadow','ad','rhds','ipa','e89ds','nds']
