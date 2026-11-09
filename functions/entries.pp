# Resolve a `*_entries` Hash parameter, or its deprecated Array form.
#
# Each entry's `ensure` defaults to `present`.
#
# Before 11.0.0 the Array replaced the module's default list, so while it is
# set it is used *instead of* the Hash. A site's existing Array data then
# keeps meaning exactly what it did, whatever the Hash holds, including Hash
# entries from the `simp:defaults` profile. An Array entry prefixed with `--`
# (a Hiera knockout) becomes `absent`.
#
# @param entries
#   The entries, each mapped to its options
#
# @param legacy
#   The entries of the deprecated Array parameter
#
# @return [Hash[String[1], Enum['present', 'absent']]]
#   Each entry mapped to its resolved `ensure`
#
# @example
#   sssd::entries({ 'nss' => {}, 'ssh' => { 'ensure' => 'absent' } })
#
#   # => { 'nss' => 'present', 'ssh' => 'absent' }
#
# @example With the deprecated Array set
#   sssd::entries({ 'nss' => {} }, ['pam', '--ssh'])
#
#   # => { 'pam' => 'present', 'ssh' => 'absent' }
#
function sssd::entries (
  Hash[String[1], Sssd::EntryOptions] $entries,
  Array[String[1]]                    $legacy = [],
) >> Hash[String[1], Enum['present', 'absent']] {
  if empty($legacy) {
    $entries.reduce({}) |$memo, $entry| {
      $memo + { $entry[0] => pick($entry[1]['ensure'], 'present') }
    }
  }
  else {
    $legacy.reduce({}) |$memo, $entry| {
      $memo + ($entry =~ /^--/ ? {
          true    => { $entry.regsubst(/^--/, '') => 'absent' },
          default => { $entry => 'present' },
      })
    }
  }
}
