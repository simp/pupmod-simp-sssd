# Whether the sudo responder is turned on by the services list
#
# It is turned off when `sudo` is `absent` in the `services_entries` Hash, or
# the deprecated Array is set without it, so that enforcing `simp:defaults`
# doesn't start a responder a site dropped from its list.
#
# Computed from class parameters only, so every caller gets the same answer
# whatever order the classes are evaluated in.
#
# @param entries
#   The `sssd::services_entries` Hash
#
# @param legacy
#   The deprecated `sssd::services` Array, or `undef` when it is unset
#
# @return [Boolean]
#
function sssd::sudo_on (
  Hash[String[1], Sssd::EntryOptions] $entries,
  Optional[Array[String[1]]]          $legacy = undef,
) >> Boolean {
  $_entry = sssd::entries($entries, $legacy)['sudo']

  $_entry == 'present' or ($_entry =~ Undef and $legacy =~ Undef)
}
