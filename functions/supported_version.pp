# Returns ``true`` if the version of SSSD installed on the system is supported
# and ``false`` otherwise.
#
# Assumes that the system is relatively modern and therefore, supported by default
#
# @return [Boolean]
#
function sssd::supported_version {
  if $facts['sssd_version'] and (versioncmp($facts['sssd_version'], '1.16.0') < 0) {
    false
  }
  else {
    true
  }
}
