#  List of valid  SSSD domain access providers
type Sssd::AccessProvider = Enum['permit','deny','ldap','ipa', 'ad','simple']
