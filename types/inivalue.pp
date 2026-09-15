# @summary A single value for an ``sssd.conf`` setting
#
# Newlines are rejected because the renderer emits one ``key = value`` line
# per entry; a newline in a value would let it forge a new ``[section]``
# header.  Brackets are *allowed* -- they are legitimate in values such as
# ``re_expression``, which contains regex character classes.
#
# ``Array`` values are rendered as comma-separated lists, so their elements
# may not contain a comma, and -- unlike a scalar value -- may not be empty.
#
# The empty String is accepted for a scalar value: ``key =`` is meaningful to
# SSSD, which reads it as "explicitly unset" rather than "absent".
type Sssd::IniValue = Variant[
  Pattern[/\A[^\n]*\z/],
  Integer,
  Float,
  Boolean,
  Array[Variant[Pattern[/\A[^\n,]+\z/], Integer, Float], 1]
]
