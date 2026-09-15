# @summary A single element of a comma-separated ``sssd.conf`` list value
#
# ``sssd.conf`` has no quoting or escaping mechanism, so an element may contain
# neither a comma -- which sssd would read as a separator, silently splitting
# one entry into two -- nor a newline, which would let it forge a new
# ``[section]`` header.  A name that genuinely contains a comma cannot be
# expressed in ``sssd.conf`` at all; rejecting it at compile time is preferable
# to rendering an access rule that never matches.
#
# Unlike a scalar value, an element may not be empty: it would render as a
# stray comma.
type Sssd::IniListItem = Pattern[/\A[^\n,]+\z/]
