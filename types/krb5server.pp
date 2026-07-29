# Valid `krb5_server`/`krb5_backup_server` value: a single host (optionally
# with a port), or a non-empty array of them. Rendered as a comma-separated
# list in the SSSD configuration.
type Sssd::Krb5Server = Variant[
  Simplib::Host,
  Simplib::Host::Port,
  Array[Variant[Simplib::Host, Simplib::Host::Port], 1]
]
