# List of valid types for sssd domain change password provider
type Sssd::ChpassProvider = Enum['ldap', 'krb5','ipa','ad', 'proxy','none']
