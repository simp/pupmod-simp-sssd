# List of valid types for sssd domain authentication provider
type Sssd::AuthProvider = Enum['ldap', 'krb5','ipa','ad', 'proxy','local', 'none']
