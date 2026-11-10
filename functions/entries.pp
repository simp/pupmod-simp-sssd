# Resolve a `*_entries` Hash parameter, or its deprecated Array form.
#
# Each entry's `ensure` defaults to `present`.
#
# Before 11.0.0 the Array replaced the module's default list, so while it is
# set, even to `[]`, it is used *instead of* the Hash, including Hash entries
# from the `simp:defaults` profile. An Array entry prefixed with `--` (a Hiera
# knockout) becomes `absent`.
#
# The Array only decides what is listed: an entry dropped from it is no longer
# managed and stays in the list until it is removed with a `--` entry.
#
# @param entries
#   The entries, each mapped to its options
#
# @param legacy
#   The entries of the deprecated Array parameter, or `undef` when it is
#   unset
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
  Optional[Array[String[1]]]          $legacy = undef,
) >> Hash[String[1], Enum['present', 'absent']] {
  if $legacy =~ Undef {
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
