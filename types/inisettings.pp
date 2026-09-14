# @summary An ``sssd.conf``-style configuration expressed as structured data
#
# A Hash of section name to a Hash of setting name to value.  Puppet Hashes
# preserve insertion order, so the rendered output is deterministic.
#
# Settings whose value is ``undef`` are dropped by the renderer, which lets a
# Hiera-supplied Hash carry a ``~`` for "leave this one out".
#
# @example
#   {
#     'nss' => {
#       'filter_users' => ['root', 'named'],
#       'memcache_timeout' => 300,
#     },
#     'domain/EXAMPLE.COM' => {
#       'id_provider' => 'ldap',
#     },
#   }
type Sssd::IniSettings = Hash[
  Sssd::IniSectionName,
  Hash[
    Pattern[/\A[a-zA-Z][a-zA-Z0-9_]*\z/],
    Optional[Sssd::IniValue]
  ]
]
