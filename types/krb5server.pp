# Valid krb5_server/krb5_backup_server
type Sssd::Krb5Server = Variant[
  Simplib::Host,
  Simplib::Host::Port,
  Array[Variant[Simplib::Host, Simplib::Host::Port], 1]
]
